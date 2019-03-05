#import "MyAudioCapture.h"

@interface MyAudioCapture() 
@end

@implementation MyAudioCapture

- (void)loadView
{
    [super loadView];
    
    UISwitch *switchButton = [UISwitch new];
    [switchButton addTarget:self action:@selector(switchButtonPressed:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:switchButton];
    
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
            [self.session startRunning];
    }
    else
    {
        if (self.session &&  self.session.isRunning)
            [self.session stopRunning];
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
    
    /* AVCaptureDeviceInput */
    {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        if (device == nil || device.connected == NO)
        {
            NSLog(@"AVCaptureDevice defaultDeviceWithMediaType failed or device not connected!");
            return -2;
        }
        NSLog(@"AVCaptureDevice localizedName:%@", device.localizedName);
        
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (!input)
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
    
    /* AVCaptureAudioDataOutput */
    {
        AVCaptureAudioDataOutput *ouput = [[AVCaptureAudioDataOutput alloc] init];
        if (!ouput)
        {
            NSLog(@"Could not create AVCaptureAudioDataOutput!");
            return -5;
        }
        
        if ([session canAddOutput:ouput] == NO)
        {
            NSLog(@"Could not addOutput to Capture Session!");
            return -6;
        }
        [session addOutput:ouput];
        
        dispatch_queue_t queue = dispatch_queue_create("com.weizhen.audioDataOutput", DISPATCH_QUEUE_SERIAL);
        [ouput setSampleBufferDelegate:self queue:queue];
    }
    
    self.session = session;
    
    return 0;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // 查询音频格式
    CMAudioFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
    const AudioStreamBasicDescription *desc = CMAudioFormatDescriptionGetStreamBasicDescription(format);
    
    // 获取音频数据
    size_t bufferListSizeNeededOut = 0;
    AudioBufferList audioBufferList = {0};
    CMBlockBufferRef blockBufferOut = 0;
    OSStatus err = CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, &bufferListSizeNeededOut, &audioBufferList, sizeof(audioBufferList), 0, 0, 0, &blockBufferOut);
    
    for (int i = 0; i < audioBufferList.mNumberBuffers; i++)
    {
        AudioBuffer *audioBuffer = audioBufferList.mBuffers + i;
        
        NSLog(@"sampleBuffer info: size = %d chns = %d, rate = %f fmt = %x fmt_flag = %d bpp = %d fpp = %d bpf = %d cpf = %d bpc = %d numberOfBuffers = %d",
              (uint)audioBuffer->mDataByteSize,
              (uint)audioBuffer->mNumberChannels,
              desc->mSampleRate,
              (uint)desc->mFormatID,
              (uint)desc->mFormatFlags,
              (uint)desc->mBytesPerPacket,
              (uint)desc->mFramesPerPacket,
              (uint)desc->mBytesPerFrame,
              (uint)desc->mChannelsPerFrame,
              (uint)desc->mBitsPerChannel,
              (uint)audioBufferList.mNumberBuffers);
        
        // 需要对这里获取的数据进行收集, 并转换成目标采样率
        // do somthing ...
    }
        
    if (err == noErr)
    {
        CFRelease(blockBufferOut);
    }
}

// 转换采样率: 采样率是指1秒钟之内, 采集多少次, 每一次采集多少. 默认的麦克风输出是采集44100次, 每次2字节(16位). 这里转成8000次, 每次2字节.
//audiox_resample_mono(sound44100, sizeof(sound44100)/sizeof(sound44100[0]), sound8000, sizeof(sound8000)/sizeof(sound8000[0]));
void audiox_resample_mono(int16_t* in_sample, int in_sample_units, int16_t* out_sample, int out_sample_units)
{
    uint32_t osample;
    /* 16+16 fixed point math */
    uint32_t isample = 0;
    uint32_t istep = ((in_sample_units-2) << 16)/(out_sample_units-2);
    
    for (osample = 0; osample < out_sample_units - 1; osample++)
    {
        int  s1;
        int  s2;
        int16_t  os;
        uint32_t t = isample&0xffff;
        
        /* don't "optimize" the (isample >> 16)*2 to (isample >> 15) */
        s1 = in_sample[(isample >> 16)];
        s2 = in_sample[(isample >> 16)+1];
        
        os = (s1 * (0x10000-t)+ s2 * t) >> 16;
        out_sample[osample] = os;
        
        isample += istep;
    }
    out_sample[out_sample_units-1] = in_sample[in_sample_units-1];
}

@end
