//
//  UIQrcodeReader.h
//  CodeReader
//
//  Created by weizhen on 16/9/27.
//  Copyright © 2016年 whmx. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIQrcodeReaderDelegate;

@interface UIQrcodeReader : UIView

@property (nonatomic, weak) id<UIQrcodeReaderDelegate> delegate;

/** 相同读码延迟4秒 */
@property (nonatomic, assign) NSTimeInterval interval;

+ (NSArray *)readFromImage:(UIImage *)image;

/** 开始扫描
 * @param rect 是扫描区域 
 */
- (void)scanRect:(CGRect)rect;

/** 曾经调用过scanRect, 设置了rect, 所以直接调用它开始扫描 */
- (void)scan;

/** 停止扫描 */
- (void)stop;

@end

@protocol UIQrcodeReaderDelegate <NSObject>

@optional

- (void)codeReader:(UIQrcodeReader *)codeReader changedStatus:(BOOL)status;

/** 
 * @param text 被扫描到的字符串
 * @return 是否停止扫描 
 */
- (BOOL)codeReader:(UIQrcodeReader *)codeReader scannedString:(NSString *)text;

@end
