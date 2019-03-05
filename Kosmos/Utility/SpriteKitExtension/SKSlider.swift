//
//  SKSlider.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/10/25.
//  Copyright © 2018 aceasy. All rights reserved.
//

import SpriteKit

/// 类似UISlider控件, 本体是SKSpriteNode, 并且拥有名为[左侧]、[右侧]、[滑块]的三个子SKSpriteNode. 在SKSlider上触摸/滑动时, 滑块会跟随手指位置移动
class SKSlider: SKControl {
    
    /// 更改此项时, 会重新布局各个节点
    var currentValue: CGFloat = 0.0 {
        
        didSet {
            
            guard currentValue <= maximumValue, currentValue >= minimumValue else {
                return NSLog("SKSlider need \"minimumValue <= currentValue <= maximumValue\"")
            }
            
            guard minimumValue < maximumValue else {
                return NSLog("SKSlider need \"minimumValue < maximumValue\"")
            }
            
            let lbar_x = lbar!.position.x
            let rbar_x = rbar!.position.x
            let lump_x = (currentValue - minimumValue) / (maximumValue - minimumValue) * (rbar_x - lbar_x) + lbar_x
            
            lump!.position = CGPointMake(lump_x, lump!.position.y)
            lbar!.size = CGSizeMake(lump_x - lbar_x, lbar!.size.height)
            rbar!.size = CGSizeMake(rbar_x - lump_x, rbar!.size.height)
        }
    }
    
    /// 更改此项时, 并不会重新布局各个节点
    var minimumValue : CGFloat = 0.0
    
    /// 更改此项时, 并不会重新布局各个节点
    var maximumValue : CGFloat = 1.0
    
    /// 滑块
    private var lump : SKSpriteNode?
    
    /// 左侧
    private var lbar : SKSpriteNode?
    
    /// 右侧
    private var rbar : SKSpriteNode?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        isUserInteractionEnabled = true
        
        lump = self["滑块"].first as? SKSpriteNode
        lbar = self["左侧"].first as? SKSpriteNode
        rbar = self["右侧"].first as? SKSpriteNode
        
        initCtrls()
    }
    
    func initCtrls() {
       
        let width = size.width
        
        lbar?.anchorPoint = CGPointMake(0.0, 0.5)
        lbar?.position = CGPointMake(-width/2, 0)
        
        rbar?.anchorPoint = CGPointMake(1.0, 0.5)
        rbar?.position = CGPointMake( width/2, 0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        var lump_x = location.x
        let lbar_x = lbar!.position.x
        let rbar_x = rbar!.position.x
        
        if  lump_x < lbar_x {
            lump_x = lbar_x
        }
        
        if  lump_x > rbar_x {
            lump_x = rbar_x
        }
        
        currentValue = (lump_x - lbar_x) / (rbar_x - lbar_x) * (maximumValue - minimumValue) + minimumValue
        
        for item in allEvents {
            if item.controlEvents.contains(.valueChanged) {
                _ = item.target.perform(item.action, with: self)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
