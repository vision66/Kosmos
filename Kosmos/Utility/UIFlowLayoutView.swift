//
//  UIFlowLayoutView.swift
//  UIFlowLayoutView
//
//  Created by weizhen on 2018/8/16.
//  Copyright © 2018年 Wuhan Mengxin Technology Co., Ltd. All rights reserved.
//

import UIKit

/// cell加入的方向
public enum UIFlowLayoutViewDirection : Int {
    
    /// 依次加入时, cell从上到下排列; 到达最下边时, 向右转行, 从最上边开始; 行宽以该行中宽度最大为准; UIFlowLayoutView必须确定高度
    case vertical
    
    /// 依次加入时, cell从左到右排列; 到达最右边时, 向下转行, 从最左边开始; 行高以该行中高度最大为准; UIFlowLayoutView必须确定宽度
    case horizontal
}

/// 这是一个类似于UICollectionViewFlowLayout布局的容器
class UIFlowLayoutView: UIView {
    
    /// 两个cell之间的间隔
    var interitemSpacing: CGFloat = 0.0
    
    /// 两行cell之间的间隔
    var lineSpacing: CGFloat = 0.0
    
    /// cell加入的方向
    var direction: UIFlowLayoutViewDirection = .horizontal
    
    ///
    weak var delegate : UIFlowLayoutViewDelegate?
    
    /// 管理cell列队
    private var cells = [UIFlowLayoutViewCell]()
    
    /// 注册cell
    private var types = [String : UIFlowLayoutViewCell.Type]()
    
    /// 点击手势
    private var tap : UITapGestureRecognizer!
    
    /// init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        addGestureRecognizer(tap)
    }
    
    /// init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// deinit
    deinit {
        removeGestureRecognizer(tap)
    }
    
    /// 注册cell
    func register(_ cellClass: UIFlowLayoutViewCell.Type, forCellWithReuseIdentifier identifier: String) {
        types[identifier] = cellClass
    }
    
    /// 取得cell
    func dequeueReusableCell(withReuseIdentifier identifier: String, for index: Int) -> UIFlowLayoutViewCell {
        
        if index >= cells.count {
            let cell = types[identifier]!.init()
            cells.append(cell)
            addSubview(cell)
            return cell
        }
        
        let cell = cells[index]
        if cell.reuseIdentifier != identifier {
            cell.removeFromSuperview()
            let newa = types[identifier]!.init()
            cells[index] = newa
            addSubview(newa)
            return newa
        }
        
        return cell
    }
    
    /// 重新加载
    func reloadRows(at indexs: [Int], with animation: Bool) {
        for index in indexs {
            delegate?.flowLayoutView(self, cellForItemAt: index).setNeedsLayout()
        }
    }
    
    /// sizeToFit()会自动调用这个方法
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        var oldLine : CGFloat = 0
        var oldCell : CGFloat = -interitemSpacing
        var maxLine : CGFloat = 0
        var maxCell : CGFloat = 0
        
        let isHorizontal = (direction == .horizontal)
        
        let preferredMaxLayoutCell = isHorizontal ? size.width : size.height
        
        let count = delegate?.numberOfItems(in: self) ?? 0
        
        for index in 0 ..< count {
            
            guard let cell = delegate?.flowLayoutView(self, cellForItemAt: index) else {
                fatalError("flowLayoutView.cellForItemAt failed")
            }
            
            var curLine = oldLine
            var curCell = oldCell + interitemSpacing
            
            let fitting = cell.intrinsicContentSize
            let fitLine = isHorizontal ? fitting.height : fitting.width
            let fitCell = isHorizontal ? fitting.width : fitting.height
            
            if  curCell + fitCell > preferredMaxLayoutCell {
                curLine = maxLine + lineSpacing
                curCell = 0
            }
            
            if isHorizontal {
                cell.frame = CGRect(x: curCell, y: curLine, width: fitCell, height: fitLine)
            } else {
                cell.frame = CGRect(x: curLine, y: curCell, width: fitLine, height: fitCell)
            }
            
            oldLine = curLine
            oldCell = curCell + fitCell
            
            if  maxLine < curLine + fitLine {
                maxLine = curLine + fitLine
            }
            
            if  maxCell < curCell + fitCell {
                maxCell = curCell + fitCell
            }
        }
        
        if isHorizontal {
            return CGSize(width: maxCell, height: maxLine)
        } else {
            return CGSize(width: maxLine, height: maxCell)
        }
    }
    
    /// ```
    /// 系统在进行AutoLayout时, 默认的调用顺序是[intrinsicContentSize -> (layoutSubviews -> 调整布局) -> ...]
    /// 本类中需要根据[设定的宽度], 来生成[内置的高度]; 在intrinsicContentSize时, 无法获取[设定的宽度]; 在layoutSubviews时, 才能取得
    /// 使用这个属性, 将调用顺序调整为[intrinsicContentSize -> (layoutSubviews -> intrinsicContentSize -> layoutSubviews -> 调整布局) -> ...]
    /// ```
    private var recalculate = false
    
    /// 当使用自动布局时, 会先调用此方法, 鉴定[内置尺寸]
    override var intrinsicContentSize: CGSize {
        
        if recalculate {
            return sizeThatFits(bounds.size)
        } else {
            return super.intrinsicContentSize
        }
    }
    
    /// 不使用自动布局时
    override func layoutSubviews() {
        
        if recalculate {
            recalculate = false
            super.layoutSubviews()
        } else {
            recalculate = true
            invalidateIntrinsicContentSize()
        }
    }
    
    ///
    @objc func tapGesture(_ recognizer: UITapGestureRecognizer) {
        
        let position = recognizer.location(in: self)
        
        guard let delegate = self.delegate else { return }
        
        guard let index = cells.index(where: { $0.frame.contains(position) }) else { return }
        
        delegate.flowLayoutView?(self, didSelectItemAt: index)
    }
}

/// UIFlowLayoutView中的一个cell
class UIFlowLayoutViewCell: UIView {
    
    var reuseIdentifier: String?
    
    var contentView = UIView()
    
    var isSelected: Bool = false
    
    var isHighlighted: Bool = false
    
    var backgroundView: UIView?
    
    var selectedBackgroundView: UIView?
    
    static var defaultIdentifier : String {
        return NSStringFromClass(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        
        NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: contentView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: contentView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return contentView.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
    }
}

/// delegate
@objc protocol UIFlowLayoutViewDelegate : NSObjectProtocol {
    
    @objc optional func flowLayoutView(_ flowLayoutView: UIFlowLayoutView, shouldHighlightItemAt index: Int) -> Bool
    
    @objc optional func flowLayoutView(_ flowLayoutView: UIFlowLayoutView, didHighlightItemAt index: Int)
    
    @objc optional func flowLayoutView(_ flowLayoutView: UIFlowLayoutView, didUnhighlightItemAt index: Int)
    
    @objc optional func flowLayoutView(_ flowLayoutView: UIFlowLayoutView, shouldSelectItemAt index: Int) -> Bool
    
    @objc optional func flowLayoutView(_ flowLayoutView: UIFlowLayoutView, shouldDeselectItemAt index: Int) -> Bool
    
    @objc optional func flowLayoutView(_ flowLayoutView: UIFlowLayoutView, didSelectItemAt index: Int)
    
    @objc optional func flowLayoutView(_ flowLayoutView: UIFlowLayoutView, didDeselectItemAt index: Int)
    
    @objc optional func flowLayoutView(_ flowLayoutView: UIFlowLayoutView, insetForSectionAt section: Int) -> UIEdgeInsets
    
    @objc optional func flowLayoutView(_ flowLayoutView: UIFlowLayoutView, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    
    func numberOfItems(in flowLayoutView: UIFlowLayoutView) -> Int
    
    func flowLayoutView(_ flowLayoutView: UIFlowLayoutView, cellForItemAt index: Int) -> UIFlowLayoutViewCell
}
