//
//  UIProgressCircle.m
//  aaaaa
//
//  Created by weizhen on 2017/1/23.
//  Copyright © 2017年 weizhen. All rights reserved.
//

#import "UIProgressCircle.h"

#define kTimerAnimationKey  @"strokeEndAnimation"

@interface UIProgressCircle() <CAAnimationDelegate> {
    CAShapeLayer *_trackLayer;  // 作为底色的环形
    CAShapeLayer *_thumbLayer;  // 将会慢慢填充的环形
    UILabel      *_textLabel;   // see self.textLabel
    UIImageView  *_imageView;   // see self.imageView
}

@end

@implementation UIProgressCircle

- (instancetype)initWithFrame:(CGRect)frame mode:(UIProgressCircleMode)mode {
    
    self = [super initWithFrame:frame];
    if (self == nil)
        return self;
    
    self.backgroundColor = UIColor.clearColor;
    _mode = mode;
    _trackColor = [UIColor whiteColor];
    _thumbColor = [UIColor grayColor];
    _trackLineWidth = 1.0;
    
    CAShapeLayer *trackLayer = [CAShapeLayer layer];
    trackLayer.fillColor     = [UIColor clearColor].CGColor;
    trackLayer.lineCap       = kCALineCapRound;
    trackLayer.lineWidth     = self.trackLineWidth;
    trackLayer.strokeStart   = 0.0;
    trackLayer.strokeEnd     = 1.0;
    [self.layer addSublayer:trackLayer];
    _trackLayer = trackLayer;
    
    CAShapeLayer *thumbLayer = [CAShapeLayer layer];
    thumbLayer.fillColor     = [UIColor clearColor].CGColor;
    thumbLayer.lineCap       = kCALineCapRound;
    thumbLayer.lineWidth     = self.trackLineWidth;
    thumbLayer.strokeStart   = 0.0;
    thumbLayer.strokeEnd     = (mode == UIProgressCircleForCounter) ? 0.0 : 1.0;
    [self.layer addSublayer:thumbLayer];
    _thumbLayer = thumbLayer;
    
    return self;
}

- (void)layoutSubviews {
    
    const CGFloat xCenter = self.bounds.size.width / 2;
    const CGFloat yCenter = self.bounds.size.height / 2;
    const CGFloat kRadius = (xCenter < yCenter ? xCenter : yCenter) - self.trackLineWidth;
    
    UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(xCenter, yCenter) radius:kRadius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    
    _trackLayer.path = circle.CGPath;
    _trackLayer.strokeColor = _trackColor.CGColor;
    _trackLayer.frame = self.bounds;
    
    _thumbLayer.path = circle.CGPath;
    _thumbLayer.strokeColor = _thumbColor.CGColor;
    _thumbLayer.frame = self.bounds;
    
    if (_textLabel) {
        _textLabel.center = CGPointMake(xCenter, yCenter);
        _textLabel.bounds = CGRectMake(0, 0, kRadius * 2, kRadius * 2);
        _textLabel.layer.cornerRadius = kRadius;
        _textLabel.layer.masksToBounds = YES;
    }
    
    if (_imageView) {
        _imageView.center = CGPointMake(xCenter, yCenter);
        _imageView.bounds = CGRectMake(0, 0, kRadius * 2, kRadius * 2);
        _imageView.layer.cornerRadius = kRadius;
        _imageView.layer.masksToBounds = YES;
    }
}

- (UILabel *)textLabel {
    if (_textLabel == nil) {
        _textLabel = [UILabel.alloc init];
        _textLabel.font = [UIFont systemFontOfSize:12];
        _textLabel.textColor = [UIColor darkGrayColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_textLabel];
    }
    return _textLabel;
}

- (UIImageView *)_imageView {
    if (_imageView == nil) {
        _imageView = [UIImageView.alloc init];
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (void)setProgress:(float)progress {
    if (_mode != UIProgressCircleForCounter)
        return;
    if (progress > 1.0) {
        progress = 1.0;
    }
    // 直接指定strokeEnd的值, 也会有动画效果
    _thumbLayer.strokeEnd = progress;
}

- (float)progress {
    return _thumbLayer.strokeEnd;
}

- (void)setTrackLineWidth:(float)trackLineWidth {
    _trackLineWidth = trackLineWidth;
    _trackLayer.lineWidth = self.trackLineWidth;
    _thumbLayer.lineWidth = self.trackLineWidth;
    [self setNeedsLayout];
}

- (void)setDuration:(float)duration {
    
    if (_mode != UIProgressCircleForTimer)
        return;
    
    if ([_thumbLayer animationForKey:kTimerAnimationKey]) {
        [_thumbLayer removeAnimationForKey:kTimerAnimationKey];
    }
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.delegate = self;
    animation.duration = duration;
    animation.fromValue = @(0.0f);
    animation.toValue = @(1.0f);
    [_thumbLayer addAnimation:animation forKey:kTimerAnimationKey];
}

- (float)duration {
    CABasicAnimation *animation = (CABasicAnimation *)[_thumbLayer animationForKey:kTimerAnimationKey];
    if (animation == nil) {
        return 0.0;
    }
    return animation.duration;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    // 动画完成时, 才会发送ValueChanged事件
    if (flag) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }    
}

@end
