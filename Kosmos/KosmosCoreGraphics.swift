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
    
    /// size scaled to fit with fixed aspect. remainder is transparent
    func scaleAspectFit(by size: CGSize) -> CGRect {
        var size_w = size.width
        var size_h = size.height
        let size_rate = size.width / size.height
        if size_rate < self.size.width / self.size.height {
            size_w = self.size.height * size_rate
            size_h = self.size.height
        } else {
            size_w = self.size.width
            size_h = self.size.width / size_rate
        }
        return CGRect(x: self.origin.x + self.size.width / 2 - size_w / 2, y: self.origin.y + self.size.height / 2 - size_h / 2, width: size_w, height: size_h)
    }
    
    /// size scaled to fill with fixed aspect. some portion of content may be clipped.
    func scaleAspectFill(by size: CGSize) -> CGRect {
        var size_w = size.width
        var size_h = size.height
        let size_rate = size.width / size.height
        if size_rate > self.size.width / self.size.height {
            size_w = self.size.height * size_rate
            size_h = self.size.height
        } else {
            size_w = self.size.width
            size_h = self.size.width / size_rate
        }
        return CGRect(x: self.origin.x + self.size.width / 2 - size_w / 2, y: self.origin.y + self.size.height / 2 - size_h / 2, width: size_w, height: size_h)
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
