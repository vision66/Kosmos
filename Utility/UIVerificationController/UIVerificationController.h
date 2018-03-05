#import <UIKit/UIKit.h>
#import "UIVerification.h"

@interface UIVerificationController : UIViewController

@property (nonatomic, strong) dispatch_block_t completion;

- (id)initWithVerificationType:(UIVerificationType)type;

@end
