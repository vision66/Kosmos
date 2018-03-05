#import <UIKit/UIKit.h>

#define kCTObjectAttributeName  @"NSCoreTextRunObject"

typedef NS_ENUM(NSInteger, NSCoreTextRunType) {
    NSCoreTextRunTypeFace, // 表情
    NSCoreTextRunTypeLink, // 链接
};

@interface NSCoreTextRun : NSObject

@property (nonatomic, assign) CGFloat ascender;     // for CTRunDelegateCallbacks

@property (nonatomic, assign) CGFloat descender;    // for CTRunDelegateCallbacks

@property (nonatomic, assign) CGFloat width;        // for CTRunDelegateCallbacks

@property (nonatomic, strong) UIImage *image;       // for NSCoreTextRunTypeFace

@property (nonatomic, copy)   NSString *text1;      // eg: "{face:smile}", "{text:接受}"

@property (nonatomic, copy)   NSString *text2;      // eg: "smile", "接受"

@property (nonatomic, assign) NSRange range;        // 解析后的文本要绘制的区域

@property (nonatomic, assign) BOOL touchEnabled;    // 这个Range是否接受点击事件

@property (nonatomic, assign) NSCoreTextRunType type;

@end

#pragma mark -

@interface MyCoreText : UIView

@property (nonatomic, copy)     NSString *text;        // 原文

@property (nonatomic, copy)     NSString *textAnalyzed; // 解析后的text

@property (nonatomic, copy)     NSMutableAttributedString *textAttributed;    // 添加属性后的textAnalyzed

@property (nonatomic, strong)   UIFont *font;          // default is [UIFont systemFontOfSize:12.0]

@property (nonatomic, strong)   UIColor *textColor;    // default is [UIColor blackColor]

@property (nonatomic, assign)   float lineHeight;       // default is 20.0

@property (nonatomic, strong)   NSMutableArray *attributedArray;       // 特殊的数组. 用于辅助添加属性, 判断区域

@property (nonatomic, strong)   NSMutableDictionary *rectDictionary;   // 绘图边界字典. 用来做点击处理定位

@end

#pragma mark - 

@interface MyCoreTextController : UIViewController

@end