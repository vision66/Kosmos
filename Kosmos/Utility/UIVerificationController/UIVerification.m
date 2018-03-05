#import "UIVerification.h"
#import "UIVerificationNavigation.h"
#import "UIVerificationInfomation.h"
#import "UIVerificationKeycontrol.h"

@interface UIVerification() <UIVerificationKeycontrolDelegate>

@property (nonatomic, strong) UIVerificationNavigation *navigation;

@property (nonatomic, strong) UIVerificationInfomation *infomation;

@property (nonatomic, strong) UIVerificationInfomation *background;

@property (nonatomic, strong) UIVerificationKeycontrol *keycontrol;

@property (nonatomic, assign) UIVerificationType type;

@property (nonatomic, assign) BOOL theOldPasswordOK; // 重置密码: 验证当前密码成功

@end

@implementation UIVerification

- (id)initWithVerificationType:(UIVerificationType)type
{
    self = [super init];
    if (self == nil)
        return self;
    
    self.backgroundColor = [UIColor grayColor];
    self.layer.masksToBounds = YES;
    
    UIVerificationNavigation *navigation = [[UIVerificationNavigation alloc] init];
    [navigation addTarget:self action:@selector(cancelButtonClicked:) forCancelButtonEvents:UIControlEventTouchUpInside];
    [self addSubview:navigation];
    self.navigation = navigation;
    
    UIVerificationInfomation *infomation = [[UIVerificationInfomation alloc] init];
    [self addSubview:infomation];
    self.infomation = infomation;
    
    UIVerificationInfomation *background = [[UIVerificationInfomation alloc] init];
    [self addSubview:background];
    self.background = background;
    
    UIVerificationKeycontrol *keyboard = [[UIVerificationKeycontrol alloc] init];
    keyboard.delegate = self;
    [self addSubview:keyboard];
    self.keycontrol = keyboard;
    
    self.type = type;
    
    if (self.type == UIVerificationTypeVerify)
    {
        self.navigation.title = @"验证密码";
        self.navigation.hideCancelButton = YES;
        
        self.infomation.field = @"";
        self.infomation.title = @"请输入当前密码";
    }
    if (self.type == UIVerificationTypeDelete)
    {
        self.navigation.title = @"删除密码";
        self.navigation.hideCancelButton = NO;
        
        self.infomation.field = @"";
        self.infomation.title = @"请输入当前密码";
    }
    if (self.type == UIVerificationTypeCreate)
    {
        self.navigation.title = @"创建密码";
        self.navigation.hideCancelButton = NO;
        
        self.infomation.field = @"";
        self.infomation.title = @"请输入新密码";
    }
    if (self.type ==  UIVerificationTypeModify)
    {
        self.navigation.title = @"修改密码";
        self.navigation.hideCancelButton = NO;
        
        self.infomation.field = @"";
        self.infomation.title = @"请输入当前密码";
    }
    
    return self;
}

- (void)layoutSubviews
{
    float sfw = self.bounds.size.width;
    float sfh = self.bounds.size.height;
    
    self.navigation.frame = CGRectMake(0, 0, sfw, 64);
    self.infomation.frame = CGRectMake(0, 64, sfw, sfh-64-216);
    self.background.frame = CGRectMake(sfw, 64, sfw, sfh-64-216);
    self.keycontrol.frame = CGRectMake(0, sfh-216, sfw, 216);
}

- (void)cancelButtonClicked:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(verificationCancelled:)])
    {
        [self.delegate verificationCancelled:self];
    }
}

- (void)calcNextOperation
{
    if (self.type == UIVerificationTypeVerify)
    {
        [self calcForVerify];
        return;
    }
    if (self.type == UIVerificationTypeDelete)
    {
        [self calcForDelete];
        return;
    }
    if (self.type == UIVerificationTypeCreate)
    {
        [self calcForCreate];
        return;
    }
    
    if (self.type == UIVerificationTypeModify)
    {
        [self calcForModify];
        return;
    }
}

- (void)calcForVerify
{
    if ([self.infomation.field compare:self.theOldPassword] == NSOrderedSame)
    {
        self.infomation.error = @"密码正确!";
        if (self.delegate && [self.delegate respondsToSelector:@selector(verification:completeAtType:)])
        {
            [self.delegate verification:self completeAtType:self.type];
        }
    }
    else
    {
        self.infomation.error = @"密码错误, 请重试!";
        self.infomation.field = @"";
        
        CGPoint center = self.infomation.center;
        
        // 显示左右震动的效果
        [UIView animateWithDuration:0.05 animations:^{
            self.infomation.center = CGPointMake(center.x + 10, center.y);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.10 animations:^{
                self.infomation.center = CGPointMake(center.x - 10, center.y);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.05 animations:^{
                    self.infomation.center = CGPointMake(center.x, center.y);
                } completion:^(BOOL finished) {
                    
                }];
            }];
        }];
    }
}

- (void)calcForDelete
{
    if ([self.infomation.field compare:self.theOldPassword] == NSOrderedSame)
    {
        self.infomation.error = @"密码正确!";
        if (self.delegate && [self.delegate respondsToSelector:@selector(verification:completeAtType:)])
        {
            [self.delegate verification:self completeAtType:self.type];
        }
    }
    else
    {
        self.infomation.error = @"密码错误, 请重试!";
        self.infomation.field = @"";
        
        CGPoint center = self.infomation.center;
        
        // 显示左右震动的效果
        [UIView animateWithDuration:0.05 animations:^{
            self.infomation.center = CGPointMake(center.x + 10, center.y);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.10 animations:^{
                self.infomation.center = CGPointMake(center.x - 10, center.y);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.05 animations:^{
                    self.infomation.center = CGPointMake(center.x, center.y);
                } completion:^(BOOL finished) {
                    
                }];
            }];
        }];
    }
}

- (void)calcForCreate
{
    if (self.theNewPassword.length == 0)
    {
        self.theNewPassword = self.infomation.field;
        
        CGRect frame = self.infomation.frame;
        self.background.frame = CGRectMake(frame.origin.x + frame.size.width, frame.origin.y, frame.size.width, frame.size.height);
        self.background.title = @"请再次输入密码";
        self.background.error = @"";
        self.background.field = @"";

        // 显示向左移动的效果
        [UIView animateWithDuration:0.5 animations:^{
            self.infomation.frame = CGRectMake(frame.origin.x - frame.size.width, frame.origin.y, frame.size.width, frame.size.height);
            self.background.frame = CGRectMake(frame.origin.x,                    frame.origin.y, frame.size.width, frame.size.height);
        } completion:^(BOOL finished) {
            UIVerificationInfomation *temp = self.infomation;
            self.infomation = self.background;
            self.background = temp;
        }];
    }
    else
    {
        if ([self.infomation.field compare:self.theNewPassword] == NSOrderedSame)
        {
            self.infomation.error = @"密码正确!";
            if (self.delegate && [self.delegate respondsToSelector:@selector(verification:completeAtType:)])
            {
                [self.delegate verification:self completeAtType:self.type];
            }
        }
        else
        {
            self.theNewPassword = @"";
            
            CGRect frame = self.infomation.frame;
            self.background.frame = CGRectMake(frame.origin.x - frame.size.width, frame.origin.y, frame.size.width, frame.size.height);
            self.background.title = @"请输入新密码";
            self.background.error = @"两次输入的密码不同, 请重试!";
            self.background.field = @"";
            
            // 显示向右移动的效果
            [UIView animateWithDuration:0.5 animations:^{
                self.infomation.frame = CGRectMake(frame.origin.x + frame.size.width, frame.origin.y, frame.size.width, frame.size.height);
                self.background.frame = CGRectMake(frame.origin.x,                    frame.origin.y, frame.size.width, frame.size.height);
            } completion:^(BOOL finished) {
                UIVerificationInfomation *temp = self.infomation;
                self.infomation = self.background;
                self.background = temp;
            }];
        }
    }
}

- (void)calcForModify
{
    if (self.theOldPasswordOK == NO)
    {
        if ([self.infomation.field compare:self.theOldPassword] == NSOrderedSame)
        {
            self.theOldPasswordOK = YES;
            
            CGRect frame = self.infomation.frame;
            self.background.frame = CGRectMake(frame.origin.x + frame.size.width, frame.origin.y, frame.size.width, frame.size.height);
            self.background.title = @"请输入新密码";
            self.background.error = @"验证通过!";
            self.background.field = @"";
            
            // 显示向左移动的效果
            [UIView animateWithDuration:0.5 animations:^{
                self.infomation.frame = CGRectMake(frame.origin.x - frame.size.width, frame.origin.y, frame.size.width, frame.size.height);
                self.background.frame = CGRectMake(frame.origin.x,                    frame.origin.y, frame.size.width, frame.size.height);
            } completion:^(BOOL finished) {
                UIVerificationInfomation *temp = self.infomation;
                self.infomation = self.background;
                self.background = temp;
            }];
        }
        else
        {
            self.infomation.error = @"密码错误, 请重试!";
            self.infomation.field = @"";
            
            CGPoint center = self.infomation.center;
            
            // 显示左右震动的效果
            [UIView animateWithDuration:0.05 animations:^{
                self.infomation.center = CGPointMake(center.x + 10, center.y);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.10 animations:^{
                    self.infomation.center = CGPointMake(center.x - 10, center.y);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.05 animations:^{
                        self.infomation.center = CGPointMake(center.x, center.y);
                    } completion:^(BOOL finished) {
                        
                    }];
                }];
            }];
        }
    }
    else if (self.theNewPassword.length == 0)
    {
        self.theNewPassword = self.infomation.field;
        
        CGRect frame = self.infomation.frame;
        self.background.frame = CGRectMake(frame.origin.x + frame.size.width, frame.origin.y, frame.size.width, frame.size.height);
        self.background.title = @"请确认密码";
        self.background.error = @"";
        self.background.field = @"";
        
        // 显示向左移动的效果
        [UIView animateWithDuration:0.5 animations:^{
            self.infomation.frame = CGRectMake(frame.origin.x - frame.size.width, frame.origin.y, frame.size.width, frame.size.height);
            self.background.frame = CGRectMake(frame.origin.x,                    frame.origin.y, frame.size.width, frame.size.height);
        } completion:^(BOOL finished) {
            UIVerificationInfomation *temp = self.infomation;
            self.infomation = self.background;
            self.background = temp;
        }];
    }
    else
    {
        if ([self.infomation.field compare:self.theNewPassword] == NSOrderedSame)
        {
            self.infomation.error = @"修改密码成功!";
            if (self.delegate && [self.delegate respondsToSelector:@selector(verification:completeAtType:)])
            {
                [self.delegate verification:self completeAtType:self.type];
            }
        }
        else
        {
            self.theNewPassword = @"";
            
            CGRect frame = self.infomation.frame;
            self.background.frame = CGRectMake(frame.origin.x - frame.size.width, frame.origin.y, frame.size.width, frame.size.height);
            self.background.title = @"请输入新密码";
            self.background.error = @"与上次的密码不同!";
            self.background.field = @"";
            
            // 显示向右移动的效果
            [UIView animateWithDuration:0.5 animations:^{
                self.infomation.frame = CGRectMake(frame.origin.x + frame.size.width, frame.origin.y, frame.size.width, frame.size.height);
                self.background.frame = CGRectMake(frame.origin.x,                    frame.origin.y, frame.size.width, frame.size.height);
            } completion:^(BOOL finished) {
                UIVerificationInfomation *temp = self.infomation;
                self.infomation = self.background;
                self.background = temp;
            }];
        }
    }
}

- (void)verificationKeycontrol:(UIVerificationKeycontrol *)verificationKeycontrol buttonValue:(NSString *)buttonValue
{
    if ([buttonValue compare:@"/"] == NSOrderedSame)
    {
        return;
    }
    
    if ([buttonValue compare:@"<"] == NSOrderedSame)
    {
        if (self.infomation.field.length > 0)
        {
            self.infomation.field = [self.infomation.field substringToIndex:self.infomation.field.length - 1];
        }
        return;
    }
    
    if (self.infomation.field.length < 4)
    {
        self.infomation.error = @""; // 正在编辑时, 清理掉之前的错误提示
        self.infomation.field = [self.infomation.field stringByAppendingString:buttonValue];
        
        if (self.infomation.field.length == 4)
        {
            [self performSelector:@selector(calcNextOperation) withObject:nil afterDelay:0.2];
        }
    }
}

@end
