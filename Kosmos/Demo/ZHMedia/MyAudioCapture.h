#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MyAudioCapture : UIViewController <AVCaptureAudioDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *session;

@end
