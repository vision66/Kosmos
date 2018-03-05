#import "UIVerificationKeycontrol.h"

@interface UIVerificationKeycontrol()

@end

@implementation UIVerificationKeycontrol

- (id)init
{
    self = [super init];
    if (self == nil)
        return self;
 
    self.backgroundColor = [UIColor grayColor];
    
    for (int i = 0; i < 12; i++)
    {
        NSString *imageNamed0 = [NSString stringWithFormat:@"bgVerification%02dnn.png", i + 1];
        NSString *imageNamed1 = [NSString stringWithFormat:@"bgVerification%02dnh.png", i + 1];
        
        UIImage *image0 = [UIImage imageNamed:imageNamed0];
        UIImage *image1 = [UIImage imageNamed:imageNamed1];
        
        UIButton *button = [[UIButton alloc] init];
        [button setBackgroundImage:image0 forState:UIControlStateNormal];
        [button setBackgroundImage:image1 forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    
    return self;
}

- (void)layoutSubviews
{
    float sw = self.bounds.size.width;
    float sh = self.bounds.size.height;
    float sp = 1.0; // 分割线
    float bw = (sw - sp * 2) / 3; // 按钮宽度
    float bh = (sh - sp * 3) / 4; // 按钮高度
    
    for (int row = 0; row < 4; row++)
    {
        for (int col = 0; col < 3; col++)
        {
            int idx = row * 3 + col;
            UIButton *button = [self.subviews objectAtIndex:idx];
            [button setFrame:CGRectMake(col * bw + col * sp, row * bh + row * sp, bw, bh)];
        }
    }
}

- (void)buttonPressed:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(verificationKeycontrol:buttonValue:)])
    {
        NSArray *titleArray = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"/", @"0", @"<"];
        
        NSUInteger index = [self.subviews indexOfObject:button];
        
        NSString *title = [titleArray objectAtIndex:index];
        
        [self.delegate verificationKeycontrol:self buttonValue:title];
    }
}

@end
