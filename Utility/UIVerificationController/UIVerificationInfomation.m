#import "UIVerificationInfomation.h"

@interface UIVerificationInfomation()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *errorLabel;

@property (nonatomic, strong) NSMutableArray *imageViewArray;

@end

@implementation UIVerificationInfomation

- (id)init
{
    self = [super init];
    if (self == nil)
        return self;
    
    self.backgroundColor = [UIColor lightGrayColor];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UILabel *errorLabel = [[UILabel alloc] init];
    errorLabel.textAlignment = NSTextAlignmentCenter;
    errorLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:errorLabel];
    self.errorLabel = errorLabel;
    
    self.imageViewArray = [NSMutableArray arrayWithCapacity:4];
    for (int i = 0; i < 4; i++)
    {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:@"bgVerification14nn.png"];
        [self addSubview:imageView];
        [self.imageViewArray addObject:imageView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    float sfw = self.bounds.size.width;
    float sfh = self.bounds.size.height;
    float scx = sfw / 2;
    float scy = sfh / 2;
    float bgs = 20; // 圆点之间的间隔
    float bgw = 40; // 圆点的宽高
    
    self.titleLabel.frame = CGRectMake(0, scy - 60, sfw, 30);
    self.errorLabel.frame = CGRectMake(0, scy + 30, sfw, 30);

    for (int i = 0; i < self.imageViewArray.count; i++)
    {
        UIImageView *imageView = [self.imageViewArray objectAtIndex:i];
        imageView.frame = CGRectMake((scx - bgw * 2 - bgs * 1.5) + i * (bgw + bgs), scy - bgw * 0.5, bgw, bgw);
    }
}

- (void)setField:(NSString *)field
{
    _field = field;
    
    for (int i = 0; i < self.imageViewArray.count; i++)
    {
        UIImageView *imageView = [self.imageViewArray objectAtIndex:i];
        imageView.image = (i < _field.length) ? [UIImage imageNamed:@"bgVerification14nn.png"] : [UIImage imageNamed:@"bgVerification14nh.png"];
    }
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (NSString *)title
{
    return self.titleLabel.text;
}

- (void)setError:(NSString *)error
{
    self.errorLabel.text = error;
}

- (NSString *)error
{
    return self.errorLabel.text;
}

@end
