//
//  SKControl.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/10/25.
//  Copyright © 2018 aceasy. All rights reserved.
//

import SpriteKit

class SKControl: SKSpriteNode {

    var allEvents = [(target: AnyObject, action: Selector, controlEvents: UIControl.Event)]()
    
    func addTarget(_ target: AnyObject, action: Selector, for controlEvents: UIControl.Event) {
        if allEvents.contains(where: { $0.target === target && $0.action == action && $0.controlEvents == controlEvents }) == false {
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
}
