//
//  UIProgressCircle.swift
//  Library
//
//  Created by weizhen on 2018/3/9.
//  Copyright © 2018年 Wuhan Mengxin Technology Co., Ltd. All rights reserved.
//

import UIKit

enum UIProgressCircleMode {
    case timer   // 用于计时: 100%的进度, 将在指定时间内(duration)均匀的跑完
    case counter // 用于下载: 进度(progress)的更新不均匀, 甚至可能倒退
}

class UIProgressCircle: UIButton, CAAnimationDelegate {
    
    /// 这个控件是用于计时(timer)还是计数(counter)
    let mode : UIProgressCircleMode
    
    /// 进度条的颜色
    var thumbColor = UIColor.gray
    
    /// 进度条的背景
    var trackColor = UIColor.white
    
    /// 进度条的线条宽度, 默认是1.0
    var trackLineWidth : CGFloat = 1.0 {
        didSet {
            trackLayer.lineWidth = self.trackLineWidth
            thumbLayer.lineWidth = self.trackLineWidth
            setNeedsLayout()
        }
    }
    
    /// 加载动画的key
    private let animationKey = "strokeEndAnimation"
    
    /// 作为底色的环形
    private var trackLayer = CAShapeLayer()
    
    /// 将会慢慢填充的环形
    private var thumbLayer = CAShapeLayer()
    
    init(frame: CGRect, mode: UIProgressCircleMode) {
        
        self.mode = mode
        
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        trackLayer.fillColor     = UIColor.clear.cgColor
        trackLayer.lineCap       = kCALineCapRound
        trackLayer.lineWidth     = self.trackLineWidth
        trackLayer.strokeStart   = 0.0
        trackLayer.strokeEnd     = 1.0
        layer.addSublayer(trackLayer)
        
        thumbLayer.fillColor     = UIColor.clear.cgColor
        thumbLayer.lineCap       = kCALineCapRound
        thumbLayer.lineWidth     = self.trackLineWidth
        thumbLayer.strokeStart   = 0.0
        thumbLayer.strokeEnd     = (mode == .counter) ? 0.0 : 1.0
        layer.addSublayer(thumbLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        let xCenter = self.bounds.size.width / 2
        let yCenter = self.bounds.size.height / 2
        let kRadius = (xCenter < yCenter ? xCenter : yCenter) - trackLineWidth
        
        let circle = UIBezierPath(arcCenter: CGPointMake(xCenter, yCenter), radius: kRadius, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        
        trackLayer.path = circle.cgPath
        trackLayer.frame = self.bounds
        trackLayer.strokeColor = trackColor.cgColor
        
        thumbLayer.path = circle.cgPath
        thumbLayer.frame = self.bounds
        thumbLayer.strokeColor = thumbColor.cgColor
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        // 动画完成时, 才会发送ValueChanged事件
        if flag {
            sendActions(for: .valueChanged)
        }
    }
    
    var duration : CGFloat { // for timer
        
        set {
            
            if mode == .counter {return}
            
            if thumbLayer.animation(forKey: animationKey) != nil {
                thumbLayer.removeAnimation(forKey: animationKey)
            }
            
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.delegate = self
            animation.duration = CFTimeInterval(newValue)
            animation.fromValue = 0.0
            animation.toValue = 1.0
            thumbLayer.add(animation, forKey: animationKey)
        }
        
        get {
            if let animation = thumbLayer.animation(forKey: animationKey) as? CABasicAnimation {
                return CGFloat(animation.duration)
            } else {
                return 0.0
            }
        }
    }
    
    var progress : CGFloat { // for counter
        
        set {
            
            if mode == .timer { return }
            
            // 直接指定strokeEnd的值, 也会有动画效果
            thumbLayer.strokeEnd = newValue
        }
        
        get {
            return thumbLayer.strokeEnd
        }
    }
}
