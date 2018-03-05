#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MyVideoCapture : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, strong) UIView *layerView;

@property (nonatomic, strong) UIImageView *imageView;

@end
