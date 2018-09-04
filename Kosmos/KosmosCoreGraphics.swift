//
//  KosmosCoreGraphics.swift
//  Kosmos
//
//  Created by weizhen on 2017/11/10.
//  Copyright © 2017年 aceasy. All rights reserved.
//

import CoreGraphics

func CGPointMake(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
    return CGPoint(x: x, y: y)
}

func CGSizeMake(_ width: CGFloat, _ height: CGFloat) -> CGSize {
    return CGSize(width: width, height: height)
}

func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
    return CGRect(x: x, y: y, width: width, height: height)
}

extension CGSize {
    
    /// CGSize的中心点, 其坐标系是自身
    var center : CGPoint {
        return CGPoint(x: width / 2, y: height / 2)
    }
}

extension CGRect {
    
    /// 根据center和size来生成CGRect
    init(center: CGPoint, size: CGSize) {
        self.init()
        self.origin = CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2)
        self.size = size
    }
    
    /// CGRect的中心点, 其坐标系与origin相同
    var center : CGPoint {
        return CGPoint(x: origin.x + size.width / 2, y: origin.y + size.height / 2)
    }
}

extension CGContext {
    
    func setStrokeColor(hex: Int, alpha: CGFloat) {
        self.setStrokeColor(red: ((hex >> 16) & 0xFF) / 255.0, green: ((hex >> 8) & 0xFF) / 255.0, blue: ((hex) & 0xFF) / 255.0, alpha: alpha)
    }
    
    func setFillColor(hex: Int, alpha: CGFloat) {
        self.setFillColor(red: ((hex >> 16) & 0xFF) / 255.0, green: ((hex >> 8) & 0xFF) / 255.0, blue: ((hex) & 0xFF) / 255.0, alpha: alpha)
    }
    
    func drawLine(from began: CGPoint, to ended: CGPoint) {
        beginPath()
        move(to: began)
        addLine(to: ended)
        strokePath()
    }
    
    func addLine(with point: CGPoint, startPoint: Bool) {
        if startPoint {
            move(to: point)
        } else {
            addLine(to: point)
        }
    }
}
