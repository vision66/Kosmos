//
//  UIQrcodeReader.m
//  CodeReader
//
//  Created by weizhen on 16/9/27.
//  Copyright © 2016年 whmx. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "UIQrcodeReader.h"
#import "dispatch+Kosmos.h"

@interface UIQrcodeReaderMask : UIView

@property (nonatomic, strong) NSString *text;

@property (nonatomic, assign) CGRect scanRect;

@property (nonatomic, assign) BOOL scanLineAnimaion;

@property (nonatomic, assign) CGFloat scanLine;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSMutableDictionary *markAttribute;

@end

@implementation UIQrcodeReaderMask

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.alignment = NSTextAlignmentCenter;
        NSMutableDictionary *markAttribute = [NSMutableDictionary dictionary];
        markAttribute[NSForegroundColorAttributeName] = UIColor.whiteColor;
        markAttribute[NSFontAttributeName] = [UIFont systemFontOfSize:14];
        markAttribute[NSParagraphStyleAttributeName] = style;
        self.markAttribute = markAttribute;
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(setNeedsDisplay) userInfo:nil repeats:YES];
        self.scanLineAnimaion = YES;
    }
    return self;
}

- (void)setScanRect:(CGRect)scanRect {
    _scanRect = scanRect;
    _scanLine = scanRect.origin.y;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    // 确定扫描框
    CGRect scanRect = self.scanRect;
    if (CGRectEqualToRect(CGRectZero, scanRect)) {
        scanRect = rect;
    }
    
    // 确定扫描线
    CGFloat scanLine = self.scanLine + 1;
    if (scanLine == scanRect.origin.y + scanRect.size.height) {
        scanLine = scanRect.origin.y;
    }
    self.scanLine = scanLine;
    
    // 准备画图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 填充整个背景
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.0 alpha:0.6].CGColor);
    CGContextFillRect(context, rect);
    
    // 绘制扫描框
    CGContextSetStrokeColorWithColor(context, [UIColor orangeColor].CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextStrokeRect(context, scanRect);
    
    // 填充扫描框
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGContextFillRect(context, scanRect);
    
    // 绘制扫描线
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextMoveToPoint(context, scanRect.origin.x, scanLine);
    CGContextAddLineToPoint(context, scanRect.origin.x + scanRect.size.width, scanLine);
    CGContextStrokePath(context);
    
    // 绘制提示文字
    if (self.text) {
        [self.text drawInRect:CGRectMake(0, scanRect.origin.y + scanRect.size.height + 10, rect.size.width, 50) withAttributes:self.markAttribute];
    }
}

- (void)setScanLineAnimaion:(BOOL)scanLineAnimaion {
    _scanLineAnimaion = scanLineAnimaion;
    if (scanLineAnimaion) {
        [self.timer setFireDate:[NSDate date]];
    } else {
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}

@end

@interface UIQrcodeReader () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureMetadataOutput *output;

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) UIQrcodeReaderMask *mask;

/** 上一次扫描到的字符串, 如果本次扫描到的与上次相同, 需要间隔大于interval才行 */
@property (nonatomic, strong) NSString *lastText;

/** 上一次扫描到的字符串, 如果本次扫描到的与上次相同, 需要间隔大于interval才行 */
@property (nonatomic, strong) NSDate *lastDate;

@end

@implementation UIQrcodeReader

+ (NSArray *)readFromImage:(UIImage *)image {
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    CIContext *ciContext = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@(YES)}];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:ciContext options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    NSArray *features = [detector featuresInImage:ciImage];
    return features;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        self.interval = 4.0;
        self.lastText = @"";
        self.lastDate = [NSDate date];
        
        // 初始化捕捉设备(AVCaptureDevice), 类型为AVMediaTypeVideo
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        // 用captureDevice创建输入流
        NSError *error;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (error) {
            NSLog(@"can not find input device");
            return self;
        }
        
        // 创建媒体数据输出流
        AVCaptureMetadataOutput *output = AVCaptureMetadataOutput.new;
        
        // 创建串行队列，并加媒体输出流添加到队列当中
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        // 实例化捕捉会话
        AVCaptureSession *session = AVCaptureSession.new;
        [session setSessionPreset:AVCaptureSessionPresetHigh]; //高质量采集率
        [session addInput:input];
        [session addOutput:output];
        
        // 设置将要扫描的条码格式, 这里同时能扫描到一维码和二维码
        output.metadataObjectTypes = @[AVMetadataObjectTypeCode128Code,
                                       AVMetadataObjectTypeQRCode,
                                       AVMetadataObjectTypeEAN13Code];
        
        // 显示视频图层
        AVCaptureVideoPreviewLayer *previewLayer = AVCaptureVideoPreviewLayer.new;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        previewLayer.session = session;
        previewLayer.frame = self.bounds;
        [self.layer addSublayer:previewLayer];
        
        // 添加扫描效果层
        UIQrcodeReaderMask *mask = [[UIQrcodeReaderMask alloc] init];
        mask.text = @"请将二维码或条形码置于正中间";
        mask.scanLineAnimaion = NO;
        [self addSubview:mask];
        
        // 保存相应实例
        self.mask = mask;
        self.output = output;
        self.session = session;
        self.previewLayer = previewLayer;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.mask.frame = self.bounds;
    self.previewLayer.frame = self.bounds;
}

- (void)scanRect:(CGRect)rect {
    self.output.rectOfInterest = CGRectMake(rect.origin.y / self.bounds.size.height, rect.origin.x / self.bounds.size.width, rect.size.height / self.bounds.size.height, rect.size.width / self.bounds.size.width);
    self.mask.scanRect = rect;
    self.mask.scanLineAnimaion = YES;
    dispatch_asyn_on_global(^{
        [self.session startRunning];
    });
    if (self.delegate && [self.delegate respondsToSelector:@selector(codeReader:changedStatus:)]) {
        [self.delegate codeReader:self changedStatus:YES];
    }
}

- (void)scan {
    self.mask.scanLineAnimaion = YES;
    dispatch_asyn_on_global(^{
        [self.session startRunning];
    });
    if (self.delegate && [self.delegate respondsToSelector:@selector(codeReader:changedStatus:)]) {
        [self.delegate codeReader:self changedStatus:YES];
    }
}

- (void)stop {
    dispatch_asyn_on_global(^{
        [self.session stopRunning];
    });
    self.mask.scanLineAnimaion = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(codeReader:changedStatus:)]) {
        [self.delegate codeReader:self changedStatus:NO];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    for (AVMetadataMachineReadableCodeObject *metadataObject in metadataObjects) {
        
        if ([metadataObject.type isEqualToString:AVMetadataObjectTypeQRCode] ||
            [metadataObject.type isEqualToString:AVMetadataObjectTypeCode128Code] ||
            [metadataObject.type isEqualToString:AVMetadataObjectTypeEAN13Code]) {
            
            NSString *text = metadataObject.stringValue;
            NSDate *date = [NSDate date];
            
            if ([text isEqualToString:self.lastText] && [date timeIntervalSinceDate:self.lastDate] < self.interval) {
                continue;
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(codeReader:scannedString:)] && [self.delegate codeReader:self scannedString:metadataObject.stringValue]) {
                self.lastDate = date;
                self.lastText = text;
                [self stop];
                break;
            }
        }
    }
}

@end
