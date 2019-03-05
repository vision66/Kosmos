//
//  QRCodeMask.swift
//  book
//
//  Created by weizhen on 2018/7/25.
//  Copyright © 2018年 Wuhan Mengxin Technology Co., Ltd. All rights reserved.
//

import UIKit

/// 配合QRCode使用, 展示扫描时的遮罩层
/**
 ```
private let scanner = QRCode()

private let scanmsk = QRCodeMask()

override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.darkGray
 
    let size = UIScreen.main.bounds.size
    let scanFrame = CGRect(center: CGPointMake(size.width/2, size.height/2), size: CGSizeMake(size.width * 0.5, size.width * 0.5))
    
    scanner.prepareScan(view, completion: scanCompletion)
    scanner.scanFrame = scanFrame
    
    let style = NSMutableParagraphStyle()
    style.alignment = .center
    
    let attribute = [NSAttributedString.Key.foregroundColor : UIColor.white,
                     NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                     NSAttributedString.Key.paragraphStyle : style]
    
    scanmsk.frame = view.bounds
    scanmsk.scanFrame = scanFrame
    scanmsk.attributedText = NSAttributedString(string: "将小说二维码放入扫描框中", attributes: attribute)
    view.addSubview(scanmsk)
}

override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    scanner.startScan()
    scanmsk.scanAnimation = true
}

func scanCompletion(_ stringValue: String) {
    scanmsk.scanAnimation = false
    print(stringValue)
}
 ```
 */
class QRCodeMask: UIView {
    
    /// 扫描框下的提示语
    var attributedText: NSAttributedString? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 扫描框尺寸, 应当与QRCode的scanFrame相同. 设置后扫描线的位置自动调整到扫描框顶部
    var scanFrame : CGRect = CGRect.zero {
        didSet {
            linePosition = scanFrame.origin.y
            setNeedsDisplay()
        }
    }
    
    /// 是否播放扫描线动画
    var scanAnimation : Bool = false {
        didSet {
            timer.fireDate = scanAnimation ? Date() : Date.distantFuture
        }
    }
    
    /// 扫描线的线条位置
    private var linePosition : CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// NSTimer调用了invalidate()方法, 再调用fire方法是启动不了的, 因为调用了invalidate()方法将timer作废了, 需要重新创建对象才行;
    /// 如果需要暂停, 可以调用fireDate = distantFuture()来实现暂停
    /// 如果需要重启, 可以调用fireDate = NSDate()来设置马上生效
    private var timer : Timer!
    
    /// init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        
        timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(updateLayer), userInfo: nil, repeats: true)
        timer.fireDate = Date.distantFuture
    }
    
    /// init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// deinit
    deinit {
        timer?.invalidate()
    }
    
    /// draw
    override func draw(_ rect: CGRect) {
        
        // 确定扫描框
        if scanFrame == .zero {
            scanFrame = rect
        }
        
        // 确定扫描线
        linePosition += 1
        if (linePosition > scanFrame.origin.y + scanFrame.size.height) {
            linePosition = scanFrame.origin.y
        }
        
        // 准备画图上下文
        let context = UIGraphicsGetCurrentContext()!
        
        // 填充整个背景
        context.setFillColor(UIColor(white: 0, alpha: 0.6).cgColor)
        context.fill(rect)
        
        // 绘制扫描框
        context.setStrokeColor(UIColor.orange.cgColor)
        context.setLineWidth(1)
        context.stroke(scanFrame)
        
        // 填充扫描框
        context.setBlendMode(CGBlendMode.clear)
        context.fill(scanFrame)
        
        // 绘制扫描线
        context.setBlendMode(CGBlendMode.normal)
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(1)
        context.setLineCap(CGLineCap.square)
        context.move(to: CGPoint(x: scanFrame.origin.x, y: linePosition))
        context.addLine(to: CGPoint(x: scanFrame.origin.x + scanFrame.size.width, y: linePosition))
        context.strokePath()
        
        // 绘制提示文字
        if let text = attributedText {
            text.draw(in: CGRectMake(0, scanFrame.origin.y + scanFrame.size.height + 10, rect.size.width, 50))
        }
    }
    
    ///
    @objc func updateLayer() {
        setNeedsDisplay()
    }
}
