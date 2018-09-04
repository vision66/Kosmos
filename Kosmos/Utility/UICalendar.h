//
//  UICalendar.h
//  UICalendar
//
//  Created by weizhen on 16/9/27.
//  Copyright © 2016年 Wuhan Mengxin Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UICalendarDelegate;

@interface UICalendar : UIControl

@property (nonatomic, strong) NSDate *date;

@property (nonatomic, weak) id<UICalendarDelegate> delegate;

@end

@protocol UICalendarDelegate <NSObject>

- (void)calendar:(UICalendar *)calendar selectDate:(NSDate *)date;

@end
