//
//  NSLayoutConstraintHelper.swift
//  novel
//
//  Created by weizhen on 2017/9/6.
//  Copyright © 2017年 weizhen. All rights reserved.
//

import UIKit

class NSLayoutConstraintHelper: NSObject {

    var item : Any?
    
    var multipliers = [CGFloat]()
    
    var attributes = [NSLayoutAttribute]()
    
    var constants = [CGFloat]()

    init(item: Any?, attributes:NSLayoutAttribute...) {
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

func **(left: NSLayoutConstraintHelper, right: CGPoint) -> NSLayoutConstraintHelper {
    left.multipliers = [right.x, right.y]
    return left
}

func *+(left: NSLayoutConstraintHelper, right: CGPoint) -> NSLayoutConstraintHelper {
    left.constants = [right.x, right.y]
    return left
}

func *-(left: NSLayoutConstraintHelper, right: CGPoint) -> NSLayoutConstraintHelper {
    left.constants = [-right.x, -right.y]
    return left
}

func **(left: NSLayoutConstraintHelper, right: UIEdgeInsets) -> NSLayoutConstraintHelper {
    left.multipliers = [right.left, right.right, right.top, right.bottom]
    return left
}

func *+(left: NSLayoutConstraintHelper, right: UIEdgeInsets) -> NSLayoutConstraintHelper {
    left.constants = [right.left, right.right, right.top, right.bottom]
    return left
}

func *-(left: NSLayoutConstraintHelper, right: UIEdgeInsets) -> NSLayoutConstraintHelper {
    left.constants = [-right.left, -right.right, -right.top, -right.bottom]
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

func *>(left: NSLayoutConstraintHelper, right: CGPoint) {
    left.constants = [right.x, right.y]
    left.related(by: .greaterThanOrEqual)
}

func *=(left: NSLayoutConstraintHelper, right: CGPoint) {
    left.constants = [right.x, right.y]
    left.related(by: .equal)
}

func *<(left: NSLayoutConstraintHelper, right: CGPoint) {
    left.constants = [right.x, right.y]
    left.related(by: .lessThanOrEqual)
}

func *>(left: NSLayoutConstraintHelper, right: UIEdgeInsets) {
    left.constants = [right.left, right.right, right.top, right.bottom]
    left.related(by: .greaterThanOrEqual)
}

func *=(left: NSLayoutConstraintHelper, right: UIEdgeInsets) {
    left.constants = [right.left, right.right, right.top, right.bottom]
    left.related(by: .equal)
}

func *<(left: NSLayoutConstraintHelper, right: UIEdgeInsets) {
    left.constants = [right.left, right.right, right.top, right.bottom]
    left.related(by: .lessThanOrEqual)
}


extension UIView {
    
    var lcLeft : NSLayoutConstraintHelper           { return NSLayoutConstraintHelper(item: self, attributes: .left)    }
    
    var lcRight : NSLayoutConstraintHelper          { return NSLayoutConstraintHelper(item: self, attributes: .right)    }
    
    var lcTop : NSLayoutConstraintHelper            { return NSLayoutConstraintHelper(item: self, attributes: .top)    }
    
    var lcBottom : NSLayoutConstraintHelper         { return NSLayoutConstraintHelper(item: self, attributes: .bottom)    }
    
    var lcWidth : NSLayoutConstraintHelper          { return NSLayoutConstraintHelper(item: self, attributes: .width)    }
    
    var lcHeight : NSLayoutConstraintHelper         { return NSLayoutConstraintHelper(item: self, attributes: .height)    }
    
    var lcCenterX : NSLayoutConstraintHelper        { return NSLayoutConstraintHelper(item: self, attributes: .centerX)    }
    
    var lcCenterY : NSLayoutConstraintHelper        { return NSLayoutConstraintHelper(item: self, attributes: .centerY)    }
    
    var lcSize : NSLayoutConstraintHelper           { return NSLayoutConstraintHelper(item: self, attributes: .width, .height)    }
    
    var lcCenter : NSLayoutConstraintHelper         { return NSLayoutConstraintHelper(item: self, attributes: .centerX, .centerY)    }
    
    var lcLeftAndTop : NSLayoutConstraintHelper     { return NSLayoutConstraintHelper(item: self, attributes: .left, .top)    }
    
    var lcLeftAndBottom : NSLayoutConstraintHelper  { return NSLayoutConstraintHelper(item: self, attributes: .left, .bottom)    }
    
    var lcRightAndTop : NSLayoutConstraintHelper    { return NSLayoutConstraintHelper(item: self, attributes: .right, .top)    }
    
    var lcRightAndBottom : NSLayoutConstraintHelper { return NSLayoutConstraintHelper(item: self, attributes: .right, .bottom)    }
    
    var lcLeftAndRight : NSLayoutConstraintHelper   { return NSLayoutConstraintHelper(item: self, attributes: .left, .right)    }
    
    var lcTopAndBottom : NSLayoutConstraintHelper   { return NSLayoutConstraintHelper(item: self, attributes: .top, .bottom)    }
    
    var lcAllButLeft : NSLayoutConstraintHelper     { return NSLayoutConstraintHelper(item: self, attributes: .right, .top, .bottom)    }
    
    var lcAllButRight : NSLayoutConstraintHelper    { return NSLayoutConstraintHelper(item: self, attributes: .left, .top, .bottom)    }
    
    var lcAllButTop : NSLayoutConstraintHelper      { return NSLayoutConstraintHelper(item: self, attributes: .left, .right, .bottom)    }
    
    var lcAllButBottom : NSLayoutConstraintHelper   { return NSLayoutConstraintHelper(item: self, attributes: .left, .right, .top)    }
    
    var lcEdge : NSLayoutConstraintHelper           { return NSLayoutConstraintHelper(item: self, attributes: .left, .right, .top, .bottom)    }
}


