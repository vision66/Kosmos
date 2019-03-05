//
//  SKButton.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/10/25.
//  Copyright © 2018 aceasy. All rights reserved.
//

import SpriteKit

protocol SceneClickableType {
    
    /// If a `SKButton` is pressed, this method will be called.
    ///
    /// - Parameters:
    ///   - scene: the receiving scence
    ///   - button: the receiving button
    func scene(_ scene: SKScene, click button: SKButton)
}

class SKButton: SKSpriteNode {
    
    /// 被按下时
    private(set) var isHighlighted = false {
        
        didSet {
            
            // 忽略相同的行为
            if oldValue == isHighlighted { return }
            
            // 清除所有的动作
            removeAllActions()
            
            if isHighlighted {
                
                // 按下时, 缩小、变暗、播放音效
                var actions = [SKAction]()
                
                let sound = SKAction.playSoundEffect(.buttonDown)
                actions.append(sound)
                
                if let object = textureDictionary[.highlighted] {
                    
                    let image = SKAction.setTexture(object)
                    actions.append(image)
                    
                    let scale = SKAction.scale(to: 1.00, duration: 0.15)
                    actions.append(scale)
                    
                    let color = SKAction.colorize(withColorBlendFactor: 0.00, duration: 0.15)
                    actions.append(color)
                }
                else if let object = textureDictionary[.normal] {
                    
                    let image = SKAction.setTexture(object)
                    actions.append(image)
                    
                    let scale = SKAction.scale(to: 0.99, duration: 0.15)
                    actions.append(scale)
                    
                    let color = SKAction.colorize(withColorBlendFactor: 0.50, duration: 0.15)
                    actions.append(color)
                }
                
                run(SKAction.group(actions))
                
            } else {
                
                // 弹起时, 还原
                var actions = [SKAction]()
                
                //let sound = SKAction.playSoundEffect(.buttonUp)
                //actions.append(sound)
                
                if let object = textureDictionary[.normal] {
                    let image = SKAction.setTexture(object)
                    actions.append(image)
                }
                
                let scale = SKAction.scale(to: 1.00, duration: 0.15)
                actions.append(scale)
                
                let color = SKAction.colorize(withColorBlendFactor: 0.00, duration: 0.15)
                actions.append(color)
                
                run(SKAction.group(actions))
            }
        }
    }
    
    /// 被选中时
    var isSelected = false {
        
        didSet {
            
            // 忽略相同的行为
            if oldValue == isSelected { return }
            
            // 清除所有的动作
            removeAllActions()
            
            if isSelected {
                
                if let object = textureDictionary[.selected] {
                    texture = object
                    colorBlendFactor = 0.0
                } else if let object = textureDictionary[.normal] {
                    texture = object
                    colorBlendFactor = 0.5
                }
            }
            else {
                texture = textureDictionary[.normal]
                colorBlendFactor = 0.0
            }
        }
    }
    
    /// 被禁用的
    var isEnabled : Bool {
        set { isUserInteractionEnabled = newValue }
        get { return isUserInteractionEnabled }
    }
    
    /// 各种状态
    public enum State : Int {
        
        case normal
        
        case highlighted
        
        case disabled
        
        case selected
        
        case selectedAndHighlighted
        
        case selectedAndDsabled
    }
    
    /// 各种状态下的纹理
    private var textureDictionary = [SKButton.State : SKTexture]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setTexture(texture, for: SKButton.State.normal)
        isUserInteractionEnabled = true
    }
    
    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        setTexture(texture, for: SKButton.State.normal)
        isUserInteractionEnabled = true
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let newButton = super.copy(with: zone) as! SKButton
        let states = [SKButton.State.normal, .highlighted, .disabled, .selected]
        for state in states {
            newButton.setTexture(textureDictionary[state], for: state)
        }
        return newButton
    }
    
    private var allEvents = [(target: AnyObject, action: Selector, controlEvents: UIControl.Event)]()
    
    func setTexture(_ texture: SKTexture?, for state: SKButton.State) {
        
        textureDictionary[state] = texture
        
        if isSelected && state == .selected {
            self.texture = texture
        } else if isSelected == false && state == .normal {
            self.texture = texture
        }
    }
    
    func texture(for state: SKButton.State) -> SKTexture? {
        return textureDictionary[state]
    }
    
    func addTarget(_ target: AnyObject, action: Selector, for controlEvents: UIControl.Event) {
        if allEvents.contains(where: { $0.target.pointerValue == target.pointerValue && $0.action == action && $0.controlEvents == controlEvents }) == false {
            allEvents.append((target, action, controlEvents))
        }
    }
    
    func removeTarget(_ target: AnyObject, action: Selector?, for controlEvents: UIControl.Event) {
        
        let index = allEvents.index {
            if action == nil {
                return $0.target === target && $0.controlEvents == controlEvents
            } else {
                return $0.target === target && $0.controlEvents == controlEvents && $0.action == action
            }
        }
        
        if let myIndex = index {
            allEvents.remove(at: myIndex)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isHighlighted = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isHighlighted = false
        
        guard let scene = scene else { fatalError("Button must be used within a SKScene.") }
        
        let isTouched = touches.contains { touch in
            let touchPoint = touch.location(in: scene)
            let touchedNode = scene.atPoint(touchPoint)
            return touchedNode === self || touchedNode.inParentHierarchy(self)
        }
        
        if isTouched && isUserInteractionEnabled {
            
            var done = false
            
            for myEvent in allEvents {
                if myEvent.controlEvents.contains(.touchUpInside) {
                    _ = myEvent.target.perform(myEvent.action, with: self)
                    done = true
                }
            }
            
            if done == false {
                
                if let myScene = scene as? SceneClickableType {
                    myScene.scene(scene, click: self)
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        super.touchesCancelled(touches!, with: event)
        isHighlighted = false
    }
}
