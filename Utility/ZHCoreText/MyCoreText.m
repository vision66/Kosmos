#import "MyCoreText.h"
#import <CoreText/CoreText.h>

@implementation NSCoreTextRun

@end

#pragma mark -

@implementation MyCoreText

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _text = @"";
        _textAnalyzed = @"";
        _font = [UIFont systemFontOfSize:14];
        _textColor = [UIColor blackColor];
        _lineHeight = 20;

        _attributedArray = [[NSMutableArray alloc] init];
        _rectDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    float sfy = rect.origin.y;
    float sfw = rect.size.width;
    
    //绘图上下文: 这是一个离屏, 屏幕倒置在实际屏幕的上方
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //修正坐标系: 坐标系右上为正, 绘制方向也是右上方. 以矩形为例, 以x/y为起点, 向右上方绘制w/h
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, 1.0, -1.0);
    CGContextConcatCTM(context, transform);

    //绘制
    CFRange lineRange = CFRangeMake(0, 0);
    float drawLineX = 0;
    float drawLineY = sfy - self.font.ascender; // 绘制文字的baseline, 不是矩形区域的y坐标

    [_rectDictionary removeAllObjects];
    
    CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((__bridge CFAttributedStringRef)_textAttributed);
    
    while(true)
    {
        CFIndex lineLength = CTTypesetterSuggestLineBreak(typesetter, lineRange.location, sfw);
check:
        lineRange = CFRangeMake(lineRange.location, lineLength);
        CTLineRef ctLine = CTTypesetterCreateLine(typesetter, lineRange);
        
        CFArrayRef ctRuns = CTLineGetGlyphRuns(ctLine);
        CFIndex ctRunNum = CFArrayGetCount(ctRuns);
        
        //边界检查
        CTRunRef lastRun = CFArrayGetValueAtIndex(ctRuns, ctRunNum - 1);
        CFRange lastRunRange = CTRunGetStringRange(lastRun);
        CGFloat lastRunAscent;
        CGFloat lastRunDescent;
        CGFloat lastRunWidth  = CTRunGetTypographicBounds(lastRun, CFRangeMake(0, 0), &lastRunAscent, &lastRunDescent, NULL);
        CGFloat lastRunPointX = drawLineX + CTLineGetOffsetForStringIndex(ctLine, lastRunRange.location, NULL);
        if ((lastRunWidth + lastRunPointX) > sfw)
        {
            lineLength--;
            CFRelease(ctLine);
            NSLog(@"redefine ctline");
goto check;
        }
        
        //绘制CTLine
        drawLineX = CTLineGetPenOffsetForFlush(ctLine, 0, sfw);
        CGContextSetTextPosition(context, drawLineX, drawLineY);
        CTLineDraw(ctLine, context);
        
        //CGFloat lineAscent;
        //CGFloat lineDescent;
        //CGFloat lineWidth = CTLineGetTypographicBounds(ctLine, &lineAscent, &lineDescent, NULL);
        //NSLog(@"line ==> range = (loc:%3ld, len:%3ld), num of run = %ld, draw position = {%f, %f}, ascent = %f, descent = %f, width = %f", lineRange.location, lineRange.length, ctRunNum, drawLineX, drawLineY, lineAscent, lineDescent, lineWidth);
        
        //绘制特殊单元
        for (int i = 0; i < ctRunNum; i++)
        {
            CTRunRef run = CFArrayGetValueAtIndex(ctRuns, i);

            CFRange runRange = CTRunGetStringRange(run);
            CGFloat runAscent;
            CGFloat runDescent;
            CGFloat runWidth  = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, NULL);
            CGFloat runPointX = drawLineX + CTLineGetOffsetForStringIndex(ctLine, runRange.location, NULL);
            //NSLog(@"run%d ==> ascent=%f, descent=%f, range=(loc:%3ld, len:%3ld), runWidth=%f, runPointX=%f", i, runAscent, runDescent, runRange.location, runRange.length, runWidth, runPointX);
            
            NSDictionary* attributes = (__bridge NSDictionary *)CTRunGetAttributes(run);
            NSCoreTextRun *attributed = [attributes objectForKey:kCTObjectAttributeName];
            if (attributed)
            {
                CGRect runRect;
                
                if (attributed.type == NSCoreTextRunTypeFace)
                {
                    runRect = CGRectMake(runPointX, drawLineY + runDescent, runWidth, runAscent - runDescent);
                }
                else
                {
                    runRect = CGRectMake(runPointX, drawLineY - runDescent, runWidth, runAscent + runDescent);
                }
                
                if (attributed.type == NSCoreTextRunTypeFace && attributed.image)
                {
                    CGContextDrawImage(context, runRect, attributed.image.CGImage);
                }
                
                if (attributed.touchEnabled)
                {
                    [_rectDictionary setObject:attributed forKey:[NSValue valueWithCGRect:runRect]];
                }
                
                //CGContextFillRect(context, runRect);
            }
        }

        CFRelease(ctLine);
        
        if(lineRange.location + lineRange.length >= _textAttributed.length)
        {
            break;
        }

        drawLineY -= self.lineHeight;
        lineRange.location += lineRange.length;
    }
    
    CFRelease(typesetter);
}

- (void)analyzeText
{
    [_attributedArray removeAllObjects];
    
    // 解析表情
    _textAnalyzed = [self analyzedTextToFace:_text attributeArray:_attributedArray];
    
    // 解析文字
    _textAnalyzed = [self analyzedTextToText:_textAnalyzed attributeArray:_attributedArray];
    
    // 生成属性文本
    _textAttributed = [self attributedTextWithAnalyzedText:_textAnalyzed attributeArray:_attributedArray];
}

- (NSString *)analyzedTextToFace:(NSString *)text attributeArray:(NSMutableArray *)attributeArray
{
    NSString *string = [_text copy];
    NSError *error;
    NSString *pattern = @"\\{face:(\\w+(\\.\\w+)?)\\}";
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regular matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    NSInteger offset = 0;
    
    for (NSTextCheckingResult *match in matches)
    {
        NSRange range1 = NSMakeRange(match.range.location - offset, match.range.length);
        NSRange range2 = NSMakeRange(match.range.location - offset + 6, match.range.length - 7);
        
        offset += match.range.length - 1;
        
        NSString* substr1 = [string substringWithRange:range1]; // "{face:smile}"
        NSString* substr2 = [string substringWithRange:range2]; // "smile"
        
        string = [string stringByReplacingCharactersInRange:range1 withString:@" "];
        
        NSCoreTextRun *attributed = [[NSCoreTextRun alloc] init];
        attributed.range = NSMakeRange(range1.location, 1);
        attributed.text1 = substr1;
        attributed.text2 = substr2;
        attributed.type = NSCoreTextRunTypeFace;
        
        [_attributedArray addObject:attributed];
    }
    
    return [string copy];
}

- (NSString *)analyzedTextToText:(NSString *)text attributeArray:(NSMutableArray *)attributeArray
{
    NSString *string = [text copy];
    NSError *error;
    NSString *pattern = @"\\{text:(\\w+)\\}";
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regular matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    NSInteger offset = 0;
    
    for (NSTextCheckingResult *match in matches)
    {
        NSRange range1 = NSMakeRange(match.range.location - offset, match.range.length);
        NSRange range2 = NSMakeRange(match.range.location - offset + 6, match.range.length - 7);
        
        offset += 7;
        
        NSString* substr1 = [string substringWithRange:range1]; // "{text:接受}"
        NSString* substr2 = [string substringWithRange:range2]; // "接受"
        
        string = [string stringByReplacingCharactersInRange:range1 withString:substr2];
        
        NSCoreTextRun *attributed = [[NSCoreTextRun alloc] init];
        attributed.range = NSMakeRange(range1.location, range2.length);
        attributed.text1 = substr1;
        attributed.text2 = substr2;
        attributed.type = NSCoreTextRunTypeLink;
        
        [attributeArray addObject:attributed];
    }
    
    return [string copy];
}

- (NSMutableAttributedString *)attributedTextWithAnalyzedText:(NSString *)textAnalyzed attributeArray:(NSArray *)attributeArray
{
    //初始化
    NSMutableAttributedString *textAttributed = [[NSMutableAttributedString alloc] initWithString:textAnalyzed];
    
    //设置全局
    CTFontRef cfFont = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, self.font.pointSize, NULL);
    [textAttributed addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)cfFont range:NSMakeRange(0, [textAttributed length])];
    CFRelease(cfFont);

    [textAttributed addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)self.textColor.CGColor range:NSMakeRange(0, [textAttributed length])];
    
    //设置特殊
    for (NSCoreTextRun *attributed in attributeArray)
    {
        if (attributed.type == NSCoreTextRunTypeFace)
        {
            NSString *emojiURL = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Ingredients/emoji"];
            NSDictionary *emoji = [NSDictionary dictionaryWithContentsOfFile:[emojiURL stringByAppendingString:@"/emoji.plist"]];
            NSString *name = [emoji objectForKey:attributed.text1];
            if (name)
            {
                attributed.image = [UIImage imageWithContentsOfFile:[emojiURL stringByAppendingFormat:@"/%@", name]];
            }
            
            attributed.ascender = self.font.ascender * 1.2;
            attributed.descender = self.font.descender * 1.2;
            attributed.width = (self.font.ascender - self.font.descender) * 1.2;
            
            CTRunDelegateCallbacks callbacks;
            callbacks.version      = kCTRunDelegateVersion1;
            callbacks.dealloc      = runDelegateDeallocCallback;
            callbacks.getAscent    = runDelegateGetAscentCallback;
            callbacks.getDescent   = runDelegateGetDescentCallback;
            callbacks.getWidth     = runDelegateGetWidthCallback;
            
            CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callbacks, (__bridge void *)attributed);
            [textAttributed addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:attributed.range];
            CFRelease(runDelegate);
        }
        
        if (attributed.type == NSCoreTextRunTypeLink)
        {
            attributed.touchEnabled = YES;
            
            [textAttributed addAttribute:(NSString *)kCTUnderlineStyleAttributeName value:(id)@(kCTUnderlineStyleDouble) range:attributed.range];
            [textAttributed addAttribute:(NSString *)kCTUnderlineColorAttributeName value:(id)[UIColor blackColor].CGColor range:attributed.range];
            [textAttributed addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor blueColor].CGColor range:attributed.range];
        }
        
        [textAttributed addAttribute:kCTObjectAttributeName value:attributed range:attributed.range];
    }
    
    return textAttributed;
}

- (CGFloat)textAreaHeightInWidth:(CGFloat)width
{
    CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_textAttributed);
    
    CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, width, 1000), NULL);
    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFramesetter, CFRangeMake(0, 0), path, NULL);
    CGPathRelease(path);
    
    CFArrayRef ctLines = CTFrameGetLines(ctFrame);
    
    CFIndex ctLineNum = CFArrayGetCount(ctLines);
    
    CFRelease(ctFrame);
    
    CFRelease(ctFramesetter);
    
    return ctLineNum * self.lineHeight;
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    CGPoint location = [(UITouch *)[touches anyObject] locationInView:self];
//    CGPoint runLocation = CGPointMake(location.x, - location.y);
//    
//    if (self.delegage && [self.delegage respondsToSelector:@selector(richLabel: touchBeginRun:)])
//    {
//        __weak MyCoreText *weakSelf = self;
//        [_rectDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//            CGRect rect = [(NSValue *)key CGRectValue];
//            if(CGRectContainsPoint(rect, runLocation))
//            {
//                [weakSelf.delegage richLabel:weakSelf touchBeginRun:(NSCoreTextRun *)obj];
//            }
//        }];
//    }
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    CGPoint location = [(UITouch *)[touches anyObject] locationInView:self];
//    CGPoint runLocation = CGPointMake(location.x, - location.y);
//    
//    if (self.delegage && [self.delegage respondsToSelector:@selector(richLabel: touchEndRun:)])
//    {
//        __weak MyCoreText *weakSelf = self;
//        [_rectDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//            CGRect rect = [(NSValue *)key CGRectValue];
//            if(CGRectContainsPoint(rect, runLocation))
//            {
//                [weakSelf.delegage richLabel:weakSelf touchEndRun:(NSCoreTextRun *)obj];
//            }
//        }];
//    }
//}

#pragma mark - RunDelegateCallback

void runDelegateDeallocCallback(void *refCon)
{
    
}

CGFloat runDelegateGetAscentCallback(void *refCon)
{
    NSCoreTextRun *attributed = (__bridge NSCoreTextRun *)refCon;
    return attributed.ascender;
}

CGFloat runDelegateGetDescentCallback(void *refCon)
{
    NSCoreTextRun *attributed = (__bridge NSCoreTextRun *)refCon;
    return attributed.descender;
}

CGFloat runDelegateGetWidthCallback(void *refCon)
{
    NSCoreTextRun *attributed = (__bridge NSCoreTextRun *)refCon;
    return attributed.width;
}

@end

#pragma mark - 

@implementation MyCoreTextController

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    MyCoreText *coreText = [[MyCoreText alloc] initWithFrame:CGRectMake(10, 80, 300, 400)];
    coreText.text = @"对表情进行测试, this is the first face{face:smile}, 这是第二个表情{face:cry}, 测试结束. 对文本进行测试, this is the first text{text:接受}, 这是第二个文本{text:拒绝}, 测试结束";
    [coreText analyzeText];
    [self.view addSubview:coreText];
}

@end