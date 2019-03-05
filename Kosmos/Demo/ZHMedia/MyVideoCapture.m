#import "MyVideoCapture.h"

@implementation MyVideoCapture

- (void)loadView
{
    [super loadView];
    
    UISwitch *switchButton = [UISwitch new];
    [switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:switchButton];
    
    UIView *view = [UIView new];
    view.frame = CGRectMake(8, 8, 150, 150);
    [self.view addSubview:view];
    self.layerView = view;
    
    UIImageView *imageView = [UIImageView new];
    imageView.frame = CGRectMake(162, 8, 150, 150);
    [self.view addSubview:imageView];
    self.imageView = imageView;
    
    int ret = [self setup];
    if (ret)
    {
        NSLog(@"setup AVCaptureSession error! code = %d", ret);
    }
}

- (void)switchButtonPressed:(UISwitch *)sender
{
    if (sender.on)
    {
        if (self.session && self.session.isRunning == NO)
        {
            [self.session startRunning]; // 这是一个同步方法, 会阻塞线程, 可以通过设置通知来解决, 具体要查看文档
            
            AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
            layer.frame = self.layerView.layer.bounds;
            layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            [self.layerView.layer addSublayer:layer];
        }
    }
    else
    {
        if (self.session &&  self.session.isRunning)
        {
            [self.session stopRunning]; // 同startRunning
            
            for (CALayer *layer in self.imageView.layer.sublayers)
                if ([layer isKindOfClass:[AVCaptureVideoPreviewLayer class]])
                    [layer removeFromSuperlayer];
        }
    }
}

- (int)setup
{
    NSError *error = nil;
    
    /* AVCaptureSession */
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    if (session == nil)
    {
        NSLog(@"AVCaptureSession allocation failed!");;
        return -1;
    }
    
    NSString *const kPreset = AVCaptureSessionPreset1920x1080;
    if ([session canSetSessionPreset:kPreset])
        session.sessionPreset = kPreset;
    else
        NSLog(@"AVCaptureSession not support %@", kPreset);
    
    
    /* AVCaptureDeviceInput */
    {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (device == nil || device.connected == NO)
        {
            NSLog(@"AVCaptureDevice defaultDeviceWithMediaType failed or device not connected!");
            return -2;
        }
        NSLog(@"AVCaptureDevice localizedName:%@", device.localizedName);
        
        // 想调输出的帧率, 但没起作用, 似乎一直保持30帧的速度
        [device lockForConfiguration:&error];
        if (error)
            NSLog(@"AVCaptureDevice lockForConfiguration error:%@", error);
        device.activeVideoMinFrameDuration = CMTimeMake(1, 4);
        [device unlockForConfiguration];
        
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (input == nil)
        {
            NSLog(@"AVCaptureDeviceInput allocation failed! %@", error);
            return -3;
        }
        
        if ([session canAddInput:input] == NO)
        {
            NSLog(@"Could not addInput to Capture Session!");
            return -4;
        }
        [session addInput:input];
    }
    
    /* AVCaptureVideoDataOutput */
    {
        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        if (!output)
        {
            NSLog(@"Could not create AVCaptureAudioDataOutput!");
            return -5;
        }
        output.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        
        if ([session canAddOutput:output] == NO)
        {
            NSLog(@"Could not addOutput to Capture Session!");
            return -6;
        }
        [session addOutput:output];
        
        dispatch_queue_t queue = dispatch_queue_create("com.weizhen.videoDataOutput", DISPATCH_QUEUE_SERIAL);
        [output setSampleBufferDelegate:self queue:queue];
    }
    
    self.session = session;
    
    return 0;
}

- (int)swap
{
    for (AVCaptureDeviceInput *input in self.session.inputs)
    {
        if ([input.device hasMediaType:AVMediaTypeVideo])
        {
            AVCaptureDevicePosition newPosition = (input.device.position == AVCaptureDevicePositionFront) ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;

            AVCaptureDeviceInput *newInput = nil;
            
            NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
            for (AVCaptureDevice *device in devices)
            {
                if (device.position == newPosition)
                {
                    newInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
                    break;
                }
            }
            
            if (newInput)
            {
                [self.session beginConfiguration];
                [self.session removeInput:input];
                [self.session addInput:newInput];
                [self.session commitConfiguration];
            }
        }
    }
    
    return 0;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // Example: How to deal with the sampleBuffer
    CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    // Get the pixel buffer width and height
    size_t imageW = CVPixelBufferGetWidth(imageBuffer);
    size_t imageH = CVPixelBufferGetHeight(imageBuffer);
    
    OSType imageFormat = CVPixelBufferGetPixelFormatType(imageBuffer);
    
    // print info
    NSString *formatString = nil;
    switch (imageFormat)
    {
        case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange: {formatString = @"kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange"; break;}
        case kCVPixelFormatType_422YpCbCr8: {formatString = @"kCVPixelFormatType_422YpCbCr8"; break;}
        case kCVPixelFormatType_32ARGB: {formatString = @"kCVPixelFormatType_32ARGB"; break;}
        case kCVPixelFormatType_32BGRA: {formatString = @"kCVPixelFormatType_32BGRA"; break;}
        case kCVPixelFormatType_32ABGR: {formatString = @"kCVPixelFormatType_32ABGR"; break;}
        case kCVPixelFormatType_32RGBA: {formatString = @"kCVPixelFormatType_32RGBA"; break;}
        default: {formatString = @"video frame format = others"; break;}
    }
    NSLog(@"sampleBuffer info: base address = %p, bytesPerRow = %zu, image size = %zux%zu, format=0x%x %@", baseAddress, bytesPerRow, imageW, imageH, (unsigned int)imageFormat, formatString);

    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, imageW, imageH, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);

    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakself.imageView.image = image;
    });
    
    // Release the Quartz image
    CGImageRelease(imageRef);
    
    // Free up the context
    CGContextRelease(context);
    
    // Free up the color space
    CGColorSpaceRelease(colorSpace);
    
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}

@end
