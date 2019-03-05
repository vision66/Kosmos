//
//  KosmosSpriteKit.swift
//  Kosmos
//
//  Created by weizhen on 2017/10/9.
//  Copyright © 2017年 aceasy. All rights reserved.
//

import SpriteKit

extension SKTileMapNode {
    
    /// https://developer.apple.com/library/content/documentation/Xcode/Reference/xcode_markup_formatting_ref/index.html
    /// - Parameter position: A point in the area of some tile
    /// - Returns: The coordinates in points of the center of the tile for a given position.
    func centerOfTile(atPosition position: CGPoint) -> CGPoint {
        let col = tileColumnIndex(fromPosition: position)
        let row = tileRowIndex(fromPosition: position)
        return centerOfTile(atColumn: col, row: row)
    }
}

extension SKNode {
    
    /// Searches the children of the receiving node for a node with a specific name.
    ///
    /// If more than one child share the same name, the first node discovered is returned.
    /// - Parameter name: The name to search for. This may be either the literal name of the node or a customized search string. See [Searching the Node Tree](apple-reference-documentation://hsY9-_wZau).
    /// - Returns: If a node object with that name is found, the method returns the node object. Otherwise, it returns nil.
    func labelNode(withName name: String) -> SKLabelNode? {
        return childNode(withName: name) as? SKLabelNode
    }
    
    /// as SKLabelNode
    var label : SKLabelNode? {
        return self as? SKLabelNode
    }
    
    /// as SKSpriteNode
    var sprite : SKSpriteNode? {
        return self as? SKSpriteNode
    }
    
    /// first child
    var firstChild : SKNode? {
        return children.first
    }
    
    /// first SKLabelNode
    var firstLabel : SKLabelNode? {
        for node in children {
            if let label = node as? SKLabelNode {
                return label
            }
        }
        return nil
    }
    
    /// first SKSpriteNode
    var firstSprite : SKSpriteNode? {
        for node in children {
            if let sprite = node as? SKSpriteNode {
                return sprite
            }
        }
        return nil
    }
}

extension UIGestureRecognizer {
    
    /// - Parameter scene: A SKScene object on which the gesture took place.
    /// - Returns: A point in the local coordinate system of scene that identifies the location of the gesture.
    func location(in scene: SKScene) -> CGPoint? {
        guard let view = scene.view else { return nil }
        let position = self.location(in: view)
        return scene.convertPoint(fromView: position)
    }
}
