//
//  UIQrcodeWriter.m
//  mxt1608s
//
//  Created by weizhen on 2017/1/12.
//  Copyright © 2017年 whmx. All rights reserved.
//

#import "UIQrcodeWriter.h"

@implementation UIQrcodeWriter

- (instancetype)initWithText:(NSString *)text logo:(UIImage *)logo {
 
    self = [super init];
    if (self) {
        
        // 二维码添加阴影效果
        //self.layer.shadowOffset = CGSizeMake(0, 2);
        //self.layer.shadowRadius = 2;
        //self.layer.shadowColor = [UIColor blackColor].CGColor;
        //self.layer.shadowOpacity = 0.5;
        
        self.image = [self imageFromText:text withSize:250.0f withHexColor:0x3C4A59];
        
        // 在生成的二维码中心附加一个小图片
        if (logo) {
            
            UIImageView *logoView = [UIImageView.alloc initWithImage:logo];
            logoView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:logoView];
            
            [NSLayoutConstraint constraintWithItem:logoView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
            [NSLayoutConstraint constraintWithItem:logoView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0].active = YES;
        }
    }
    
    return self;
}

- (UIImage *)imageFromText:(NSString *)text withSize:(CGFloat)size withHexColor:(NSInteger)hexColor {
    
    /* 生成二维码图片(CIImage类型) */
    CIImage *ciImage = nil;
    {
        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
        CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        [filter setValue:data forKey:@"inputMessage"];          // 设置内容
        [filter setValue:@"H" forKey:@"inputCorrectionLevel"];  // 设置纠错级别
        
        ciImage = filter.outputImage;
    }
    
    /* 生成二维码图片(UIImage类型). 根据传入的size输出适合尺寸的UIImage, 这是等比例缩放 */
    UIImage *uiImage = nil;
    {
        CGRect extent = CGRectIntegral(ciImage.extent);
        CGFloat extentW = CGRectGetWidth(extent);
        CGFloat extentH = CGRectGetHeight(extent);
        CGFloat scale = MIN(size/extentW, size/extentH);
        
        CIContext *ciContext = [CIContext contextWithOptions:nil];
        CGImageRef cgImage = [ciContext createCGImage:ciImage fromRect:extent];
        
        CGColorSpaceRef cgColorSpace = CGColorSpaceCreateDeviceGray();
        CGContextRef cgContext = CGBitmapContextCreate(nil, extentW * scale, extentH * scale, 8, 0, cgColorSpace, (CGBitmapInfo)kCGImageAlphaNone);
        CGColorSpaceRelease(cgColorSpace);
        
        CGContextSetInterpolationQuality(cgContext, kCGInterpolationNone);
        CGContextScaleCTM(cgContext, scale, scale);
        CGContextDrawImage(cgContext, extent, cgImage);
        
        CGImageRef scaledImage = CGBitmapContextCreateImage(cgContext);
        CGContextRelease(cgContext);
        CGImageRelease(cgImage);
        
        uiImage = [UIImage imageWithCGImage:scaledImage];
        CGImageRelease(scaledImage);
    }
    
    /* 输出指定颜色的二维码. 原本是黑白色的二维码, 经此操作, 将白色转为透明, 黑色转为指定色. 使用遍历图片像素来更改图片颜色, 因为使用的是CGContext, 速度非常快 */
    UIImage *resultImage;
    {
        const int imageW = uiImage.size.width;
        const int imageH = uiImage.size.height;
        size_t bytesPerRow = imageW * 4;
        uint32_t *rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageH); // free in ProviderReleaseData
        CGColorSpaceRef cgColorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef cgContext = CGBitmapContextCreate(rgbImageBuf, imageW, imageH, 8, bytesPerRow, cgColorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
        CGContextDrawImage(cgContext, CGRectMake(0, 0, imageW, imageH), uiImage.CGImage);
        
        uint8_t targetR = ((hexColor >> 16) & 0xFF);
        uint8_t targetG = ((hexColor >>  8) & 0xFF);
        uint8_t targetB = ((hexColor >>  0) & 0xFF);
        
        // 遍历像素
        int pixelNum = imageW * imageH;
        uint32_t *pCurPtr = rgbImageBuf;
        for (int i = 0; i < pixelNum; i++, pCurPtr++) {
            
            // 将白色变成透明
            if ((*pCurPtr & 0xFFFFFF00) < 0x99999900) {
                // 改成下面的代码, 会将图片转成想要的颜色
                uint8_t *ptr = (uint8_t *)pCurPtr;
                ptr[3] = targetR;
                ptr[2] = targetG;
                ptr[1] = targetB;
            } else {
                uint8_t* ptr = (uint8_t*)pCurPtr;
                ptr[0] = 0;
            }
        }
        
        // 输出图片
        CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageH, ProviderReleaseData);
        CGImageRef cgImage = CGImageCreate(imageW, imageH, 8, 32, bytesPerRow, cgColorSpace, kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
        CGDataProviderRelease(dataProvider);
        resultImage = [UIImage imageWithCGImage:cgImage];

        // 清理空间
        CGImageRelease(cgImage);
        CGContextRelease(cgContext);
        CGColorSpaceRelease(cgColorSpace);
    }
    
    return resultImage;
}

void ProviderReleaseData(void *info, const void *data, size_t size) {
    free((void *)data);
}

@end
