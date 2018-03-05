//
//  UIProgressCircle.h
//  aaaaa
//
//  Created by weizhen on 2017/1/23.
//  Copyright © 2017年 weizhen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UIProgressCircleMode) {
    UIProgressCircleForTimer,   // 用于计时: 100%的进度, 将在指定时间内(duration)均匀的跑完
    UIProgressCircleForCounter, // 用于下载: 进度(progress)的更新不均匀, 甚至可能倒退
};

@interface UIProgressCircle : UIControl

@property (nonatomic, assign, readonly) UIProgressCircleMode mode;

@property (nonatomic, assign) float progress; // for counter

@property (nonatomic, assign) float duration; // for timer

@property (nonatomic, strong) UIColor *thumbColor; // 进度条的颜色

@property (nonatomic, strong) UIColor *trackColor; // 进度条的背景

@property (nonatomic, assign) float trackLineWidth; // 进度条的线条宽度, 默认是1.0

@property (nonatomic, strong, readonly) UILabel *textLabel; // 进度条中间的文字. 默认值是nil, 但是第一次读取时, 会创建出来

@property (nonatomic, strong, readonly) UIImageView *imageView; // 进度条中间的图片. 默认值是nil, 但是第一次读取时, 会创建出来

- (instancetype)initWithFrame:(CGRect)frame mode:(UIProgressCircleMode)mode;

@end
