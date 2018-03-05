#import <UIKit/UIKit.h>

@protocol UIVerificationKeycontrolDelegate;

@interface UIVerificationKeycontrol : UIView

@property (nonatomic, strong) id<UIVerificationKeycontrolDelegate> delegate;

@end

@protocol UIVerificationKeycontrolDelegate <NSObject>

- (void)verificationKeycontrol:(UIVerificationKeycontrol *)verificationKeycontrol buttonValue:(NSString *)buttonValue;

@end