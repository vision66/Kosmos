//
//  NSLayoutConstraintHelper.swift
//  novel
//
//  Created by weizhen on 2017/9/6.
//  Copyright © 2017年 Wuhan Mengxin Technology Co., Ltd. All rights reserved.
//

import UIKit

class NSLayoutConstraintHelper: NSObject {

    var item : Any?
    
    var multipliers = [CGFloat]()
    
    var attributes = [NSLayoutAttribute]()
    
    var constants = [CGFloat]()

    init(item: Any?, attributes: NSLayoutAttribute...) {
        super.init()
        self.item = item
        self.attributes = attributes
    }
    
    func related(by relation: NSLayoutRelation, toRight: NSLayoutConstraintHelper) {
        
        let count = self.attributes.count
        
        for index in 0 ..< count {
            
            let attr1 = self.attributes[index]
            
            let attr2 = (index >= toRight.attributes.count) ? attr1 : toRight.attributes[index]
            
            let constant1 = (index >= self.constants.count) ? 0.0 : self.constants[index]
            
            let constant2 = (index >= toRight.constants.count) ? constant1 : toRight.constants[index]
            
            let multiplier1 = (index >= self.multipliers.count) ? 1.0 : self.multipliers[index]
            
            let multiplier2 = (index >= toRight.multipliers.count) ? multiplier1 : toRight.multipliers[index]
            
            NSLayoutConstraint(item: self.item!, attribute: attr1, relatedBy: relation, toItem: toRight.item!, attribute: attr2, multiplier: multiplier2, constant: constant2).isActive = true
        }
    }
    
    func related(by relation: NSLayoutRelation) {
        
        let count = self.attributes.count

        for index in 0 ..< count {

            let attr1 = self.attributes[index]

            let constant1 = (index >= self.constants.count) ? 0.0 : self.constants[index]

            NSLayoutConstraint(item: self.item!, attribute: attr1, relatedBy: relation, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: constant1).isActive = true
        }
    }
}

infix operator ** : MultiplicationPrecedence
infix operator *+ : AdditionPrecedence
infix operator *- : AdditionPrecedence
infix operator *> : ComparisonPrecedence
infix operator *= : ComparisonPrecedence
infix operator *< : ComparisonPrecedence

func **(left: NSLayoutConstraintHelper, right: CGFloat) -> NSLayoutConstraintHelper {
    left.multipliers = [right]
    return left
}

func *+(left: NSLayoutConstraintHelper, right: CGFloat) -> NSLayoutConstraintHelper {
    left.constants = [right]
    return left
}

func *-(left: NSLayoutConstraintHelper, right: CGFloat) -> NSLayoutConstraintHelper {
    left.constants = [-right]
    return left
}

//@discardableResult
func *>(left: NSLayoutConstraintHelper, right: NSLayoutConstraintHelper) {
    left.related(by: .greaterThanOrEqual, toRight: right)
}

func *=(left: NSLayoutConstraintHelper, right: NSLayoutConstraintHelper) {
    left.related(by: .equal, toRight: right)
}

func *<(left: NSLayoutConstraintHelper, right: NSLayoutConstraintHelper) {
    left.related(by: .lessThanOrEqual, toRight: right)
}

func *>(left: NSLayoutConstraintHelper, right: CGFloat) {
    left.constants = [right]
    left.related(by: .greaterThanOrEqual)
}

func *=(left: NSLayoutConstraintHelper, right: CGFloat) {
    left.constants = [right]
    left.related(by: .equal)
}

func *<(left: NSLayoutConstraintHelper, right: CGFloat) {
    left.constants = [right]
    left.related(by: .lessThanOrEqual)
}

extension UIView {
    
    var lcTop : NSLayoutConstraintHelper            { return NSLayoutConstraintHelper(item: self, attributes: .top) }
    
    var lcLeft : NSLayoutConstraintHelper           { return NSLayoutConstraintHelper(item: self, attributes: .left) }
    
    var lcRight : NSLayoutConstraintHelper          { return NSLayoutConstraintHelper(item: self, attributes: .right) }
    
    var lcBottom : NSLayoutConstraintHelper         { return NSLayoutConstraintHelper(item: self, attributes: .bottom) }
    
    var lcWidth : NSLayoutConstraintHelper          { return NSLayoutConstraintHelper(item: self, attributes: .width) }
    
    var lcHeight : NSLayoutConstraintHelper         { return NSLayoutConstraintHelper(item: self, attributes: .height) }
    
    var lcCenterX : NSLayoutConstraintHelper        { return NSLayoutConstraintHelper(item: self, attributes: .centerX) }
    
    var lcCenterY : NSLayoutConstraintHelper        { return NSLayoutConstraintHelper(item: self, attributes: .centerY) }
}
