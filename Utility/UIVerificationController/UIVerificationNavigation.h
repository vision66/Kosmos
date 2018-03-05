#import <UIKit/UIKit.h>

@interface UIVerificationNavigation : UIView

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) BOOL hideCancelButton;

- (void)addTarget:(id)target action:(SEL)action forCancelButtonEvents:(UIControlEvents)controlEvents;

@end
