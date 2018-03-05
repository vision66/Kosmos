#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UIVerificationType) {
    UIVerificationTypeVerify, // 用于验证密码
    UIVerificationTypeDelete, // 用于删除密码
    UIVerificationTypeCreate, // 用于创建密码
    UIVerificationTypeModify, // 用于修改密码
};

@protocol UIVerificationDelegate;

@interface UIVerification : UIView

@property (nonatomic, strong) id<UIVerificationDelegate> delegate;

@property (nonatomic, copy) NSString *theOldPassword; // 正在使用的密码

@property (nonatomic, copy) NSString *theNewPassword; // 重置密码/创建密码: 保存上一次的输入结果

- (id)initWithVerificationType:(UIVerificationType)type;

@end

@protocol UIVerificationDelegate <NSObject>

- (void)verificationCancelled:(UIVerification *)verification;

- (void)verification:(UIVerification *)verification completeAtType:(UIVerificationType)type; // 创建完成, 修改完成, 验证成功

@end