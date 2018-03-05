#import "UIVerificationController.h"

#define kPassord @"kPassord"

@interface UIVerificationController () <UIVerificationDelegate>

@property (nonatomic, assign) UIVerificationType type;

@property (nonatomic, strong) UIVerification *verification;

@end

@implementation UIVerificationController

- (id)initWithVerificationType:(UIVerificationType)type
{
    self = [super init];
    if (self)
    {
        self.type = type;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor colorWithWhite:100/255.0 alpha:1.0];
    
    UIVerification *verification = [[UIVerification alloc] initWithVerificationType:self.type];
    verification.translatesAutoresizingMaskIntoConstraints = NO;
    verification.delegate = self;
    [self.view addSubview:verification];
    self.verification = verification;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:verification attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX        multiplier:1 constant:0],
                                    [NSLayoutConstraint constraintWithItem:verification attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY        multiplier:1 constant:0],
                                    [NSLayoutConstraint constraintWithItem:verification attribute:NSLayoutAttributeWidth   relatedBy:NSLayoutRelationEqual toItem:nil       attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:320],
                                    [NSLayoutConstraint constraintWithItem:verification attribute:NSLayoutAttributeHeight  relatedBy:NSLayoutRelationEqual toItem:nil       attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:480]]];
    }
    else
    {
        [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:verification attribute:NSLayoutAttributeLeft   relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft   multiplier:1 constant:0],
                                    [NSLayoutConstraint constraintWithItem:verification attribute:NSLayoutAttributeRight  relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight  multiplier:1 constant:0],
                                    [NSLayoutConstraint constraintWithItem:verification attribute:NSLayoutAttributeTop    relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop    multiplier:1 constant:0],
                                    [NSLayoutConstraint constraintWithItem:verification attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.verification.theOldPassword = [[NSUserDefaults standardUserDefaults] objectForKey:kPassord];
}

- (void)verificationCancelled:(UIVerification *)verification
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)verification:(UIVerification *)verification completeAtType:(UIVerificationType)type
{
    if (type == UIVerificationTypeCreate || type == UIVerificationTypeModify)
    {
        [[NSUserDefaults standardUserDefaults] setValue:self.verification.theNewPassword forKey:kPassord];
    }
    
    if (type == UIVerificationTypeDelete)
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:kPassord];
    }
   
    [self dismissViewControllerAnimated:YES completion:self.completion];
}

@end
