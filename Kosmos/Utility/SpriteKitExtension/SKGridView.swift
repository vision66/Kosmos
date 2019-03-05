//
//  SKGridView.swift
//  TowerOfSaviors
//
//  Created by weizhen on 2018/10/15.
//  Copyright © 2018 aceasy. All rights reserved.
//

import SpriteKit

/// 类似UICollectionViewCell
class SKGridViewCell: SKShapeNode {
    
    /// 当前标识符
    var reuseIdentifier: String?
    
    /// 默认的标识符
    static var defaultIdentifier : String {
        return NSStringFromClass(self)
    }
    
    /// cell的有效区域
    var bounds : CGRect = .zero {
        didSet {
            path = CGPath(rect: bounds, transform: nil)
        }
    }
    
    /// 当cell移动到grid.bounds内时, indexPath才有值
    fileprivate(set) var indexPath : Int? = nil
    
    /// init
    required init(reuseIdentifier: String?) {
        super.init()
        //self.fillColor = UIColor.brown
        self.lineWidth = 0
        self.reuseIdentifier = reuseIdentifier
    }
    
    /// init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// 类似UICollectionView
class SKGridView: SKShapeNode {
    
    /// 委托方法
    weak var delegate: SKGridViewDelegate?
    
    /// 监听拖动
    private lazy var dragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onDragGesture(_:)))
    
    /// 禁止用户交互
    var isEnabled : Bool {
        set { isUserInteractionEnabled = newValue }
        get { return isUserInteractionEnabled }
    }
    
    /// 拖拽标识
    private var isDragging : Bool = false
    
    /// 注册的cell类型, 用于创建新cell对象
    private var cellsRegistered = [String : SKGridViewCell.Type]()
    
    /// 缓存的cells
    private var cellsCached = [SKGridViewCell]()
    
    /// cells的偏移. 初始时, 第一个cell的左上角, 与grid.bounds左上角对齐
    private var contentOffset : CGFloat = 0.0
    
    /// grid的有效区域
    var bounds : CGRect = .zero {
        didSet {
            path = CGPath(rect: bounds, transform: nil)
        }
    }
    
    /// 每个cell的宽高
    var itemSize: CGSize = CGSize(width: 40.0, height: 40.0)
    
    /// 两行cell之间的最小间隔
    var minimumLineSpacing: CGFloat = 0.0
    
    /// 两个cell之间的最小间隔
    var minimumInteritemSpacing: CGFloat = 0.0
    
    /// 当cells朝上下左右四个方向, 移动到极致时, 最后一个cell与grid至少保留这个距离
    var contentInset : UIEdgeInsets = .zero
    
    /// init
    override init() {
        super.init()
        //self.fillColor = UIColor.darkGray
        self.lineWidth = 0
        self.isUserInteractionEnabled = true
    }
    
    /// init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 父节点使用addChild(_:)时, 触发子节点的这个方法
    func didMove(to node: SKNode) {
        scene?.view?.addGestureRecognizer(dragRecognizer)
        reloadData()
    }
    
    /// 子节点使用removeFromParent()时, 触发子节点的这个方法
    func willRemove(from node: SKNode) {
        scene?.view?.removeGestureRecognizer(dragRecognizer)
    }
    
    ///
    override var isUserInteractionEnabled: Bool {
        didSet {
            dragRecognizer.isEnabled = isUserInteractionEnabled
        }
    }
    
    /// 最多几行
    private var maxRows : Int = 0
    
    /// 更新数据源后, 调用此方法, 更新界面
    func reloadData() {
        
        contentOffset = 0.0 - contentInset.top
        
        for cell in cellsCached {
            cell.removeFromParent()
        }
        
        layoutSubnodes()
    }
    
    /// 根据偏移量offsetOfCells, 布局cells. 在grid.bounds之外的cell将会removeFromParent; 在grid.bounds之d内的cell, 可能被重用
    private func layoutSubnodes() {
        
        guard let delegate = delegate else { fatalError("grid not find its delegate") }
        
        let numberOfCells = delegate.gridView(self, numberOfItems: 0)
        if numberOfCells == 0 { return }
        
        let cell_w = itemSize.width
        let cell_h = itemSize.height
        
        let grid_w = bounds.size.width
        let grid_h = bounds.size.height
        let maxColumns = floor((grid_w + minimumInteritemSpacing) / (cell_w + minimumInteritemSpacing)).asInt
        
        let interitemSpacing = (maxColumns <= 1) ? (grid_w - cell_w) : (grid_w - cell_w * maxColumns) / (maxColumns - 1)
        
        maxRows = ceil(numberOfCells * 1.0 / maxColumns).asInt
        
        let firstRow = floor(contentOffset / (cell_h + minimumLineSpacing)).asInt
        let beforeFirstRow = (firstRow <= 0) ? 0 : (firstRow - 1)
        
        let lastRow = floor((contentOffset + bounds.size.height) / (cell_h + minimumLineSpacing)).asInt
        let afterLastRow = (lastRow >= maxRows - 1) ? (maxRows - 1) : (lastRow + 1)
        
        for row in beforeFirstRow ... afterLastRow {
            
            for col in 0 ..< maxColumns {
                
                let index = row * maxColumns + col
                if index >= numberOfCells { return }
                
                let pos_x = cell_w / 2 - grid_w / 2 + (cell_w + interitemSpacing) * col
                let pos_y = grid_h / 2 - cell_h / 2 - (cell_h + minimumLineSpacing) * row + contentOffset
                let frame = CGRectMake(pos_x - cell_w / 2, pos_y - cell_h / 2, cell_w, cell_h)
                
                if frame.intersects(bounds) {
                    let cell = delegate.gridView(self, cellForItemAt: index)
                    cell.position = CGPointMake(pos_x, pos_y)
                    if cell.parent == nil {
                        addChild(cell)
                    }
                } else if let cell = cellsCached.first(where: { $0.indexPath == index }) {
                    cell.indexPath = nil
                    cell.removeFromParent()
                }
            }
        }
    }
    
    /// 根据indexPath和identifier, 从缓存中取得一个cell, 如果不存在, 将会创建一个cell
    func dequeueReusableCell(withIdentifier identifier: String, for indexPath: Int) -> SKGridViewCell {
        
        if let cell = cellsCached.first(where: { $0.reuseIdentifier == identifier && $0.indexPath == indexPath }) {
            return cell
        }
        
        if let cell = cellsCached.first(where: { $0.reuseIdentifier == identifier && $0.indexPath == nil }) {
            cell.indexPath = indexPath
            return cell
        }
        
        if let cell = cellsRegistered[identifier]?.init(reuseIdentifier: identifier) {
            cell.indexPath = indexPath
            cell.bounds = CGRectMake(-itemSize.width / 2, -itemSize.height / 2, itemSize.width, itemSize.height)
            cellsCached.append(cell)
            return cell
        }
        
        fatalError("grid not find '\(identifier)'")
    }
    
    /// 注册cell类型
    func register(_ cellClass: SKGridViewCell.Type, forCellReuseIdentifier identifier: String) {
        cellsRegistered[identifier] = cellClass
    }
    
    /// 监听拖拽
    @objc private func onDragGesture(_ recognizer: UIPanGestureRecognizer) {
        
        if recognizer.state == .began {
            guard let scene = scene else { return }
            guard let view = scene.view else { return }
            let position1 = recognizer.location(in: view)
            let position2 = scene.convertPoint(fromView: position1)
            let position3 = self.convert(position2, from: scene)
            if bounds.contains(position3) {
                isDragging = true
            }
            //if let position = recognizer.location(in: self), bounds.contains(position) {
            //    isDragging = true
            //}
            return
        }
        
        if recognizer.state == .changed && isDragging {
            dragGesture(recognizer)
            return
        }
        
        if recognizer.state == .ended {
            isDragging = false
            return
        }
    }
    
    /// 场景与屏幕的比率
    private lazy var scene_per_screen = scene!.size.width / scene!.view!.bounds.size.width
    
    /// 根据拖拽事件, 移动cells
    private func dragGesture(_ recognizer: UIPanGestureRecognizer) {
        
        guard let view = scene?.view else { fatalError("grid not in scene or view") }
        
        let changedOffset = recognizer.translation(in: view).y * scene_per_screen
        
        var targetOffset = contentOffset - changedOffset
        
        let heightOfCells = itemSize.height * maxRows + minimumLineSpacing * (maxRows - 1)
        
        // min
        let min : CGFloat = 0.0 - contentInset.top
        if targetOffset < min {
            targetOffset = min
        }

        // max
        let max : CGFloat = heightOfCells - bounds.size.height + contentInset.bottom
        if max < min {
            targetOffset = min
        } else if targetOffset > max {
            targetOffset = max
        }
        
        contentOffset = targetOffset
        
        layoutSubnodes()
        
        recognizer.setTranslation(.zero, in: view)
    }
}

/// 类似UICollectionViewDataSource
protocol SKGridViewDelegate : NSObjectProtocol {

    /// 网格中的cell数量
    func gridView(_ gridView: SKGridView, numberOfItems unuse: Int) -> Int
    
    /// 配置第n个cell
    func gridView(_ gridView: SKGridView, cellForItemAt indexPath: Int) -> SKGridViewCell
}
