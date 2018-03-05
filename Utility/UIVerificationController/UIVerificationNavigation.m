#import "UIVerificationNavigation.h"

@interface UIVerificationNavigation()

@property (nonatomic, strong) UIImageView *backgroundImage;

@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation UIVerificationNavigation

- (id)init
{
    self = [super init];
    if (self == nil)
        return self;
    
    self.backgroundColor = [UIColor greenColor];

    UIImageView *backgroundImage = [[UIImageView alloc] init];
    backgroundImage.image = [UIImage imageNamed:@"bgVerification00nn.png"];
    [self addSubview:backgroundImage];
    self.backgroundImage = backgroundImage;
    
    UIButton *cancelButton = [[UIButton alloc] init];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"bgVerification13nn.png"] forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"bgVerification13nh.png"] forState:UIControlStateHighlighted];
    [self addSubview:cancelButton];
    self.cancelButton = cancelButton;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor blackColor];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
       
    return self;
}

- (void)layoutSubviews
{
    float sw = self.bounds.size.width;
    float sh = self.bounds.size.height;
    
    self.backgroundImage.frame = CGRectMake(0, 0, sw, sh);
    self.cancelButton.frame = CGRectMake(0, 20, 54, sh-20);
    self.titleLabel.frame = CGRectMake(0, 20, sw, sh-20);
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (NSString *)title
{
    return self.titleLabel.text;
}

- (void)setHideCancelButton:(BOOL)hideCancelButton
{
    self.cancelButton.hidden = hideCancelButton;
}

- (BOOL)hideCancelButton
{
    return self.cancelButton.hidden;
}

- (void)addTarget:(id)target action:(SEL)action forCancelButtonEvents:(UIControlEvents)controlEvents
{
    [self.cancelButton addTarget:target action:action forControlEvents:controlEvents];
}

@end
