//
//  UILaunchController.swift
//  store
//
//  Created by weizhen on 2017/3/20.
//  Copyright © 2017年 Wuhan Mengxin Technology Co., Ltd. All rights reserved.
//

import UIKit


class UILaunchController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// 上一次成功执行UILaunchController时, app的版本号, 形如"1.0.1"的字符串
    private let kPreloadVersion = "launch cache version"
    
    /// 上一次成功执行UILaunchController后, 预加载的启动图. 这是一个数组, 数组元素是图片在doc中的位置, 形如"/PreloadImages-0.png", 文件名称会影响显示顺序
    private let kPreloadImages = "launch cache images"
    
    /// 用于轮播图片
    private var collectionView : UICollectionView!
    
    /// 索引指示器
    private let pageControl = UIPageControl()
    
    /// 被轮播的图片. 最后一张会被加上结束按钮
    private var images = [UIImage]()
    
    /// 描述当前app的更新状态
    enum State {
        
        /// 既不是更新后, 也没有预加载, 只是显示启动图. 没有[进入按钮], 没有[跳过按钮], 会停顿几秒后自动退出
        case `default`
        
        /// 更新之后. 存在[进入按钮], 没有[跳过按钮], 需要点击按钮才会退出
        case install
        
        /// 不是更新之后, 有预加载图. 没有[进入按钮], 存在[跳过按钮], 会停顿几秒后自动退出
        case preload
    }
    
    /// 描述当前app的更新状态
    private(set) var state : State = .default
    
    /// 通知变更
    private unowned let delegate : UILaunchControllerDelegate
    
    
    init(delegate : UILaunchControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .groupTableViewBackground
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = UIScreen.main.bounds.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.bounces = false
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UILaunchImageCell.self, forCellWithReuseIdentifier: UILaunchImageCell.defaultIdentifier)
        view.addSubview(collectionView)
        
        images = scrollImages()
                
        pageControl.center = CGPointMake(view.width / 2, view.height - 50) // 120x28
        pageControl.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
        pageControl.hidesForSinglePage = true
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .darkGray
        pageControl.numberOfPages = images.count
        view.addSubview(pageControl)
        
        if state == .preload {
            
            let frame = CGRectMake(view.width - 36 - 10, 30, 36, 36)
            
            let textLabel = UILabel()
            textLabel.frame = frame            
            textLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            textLabel.text = "跳过"
            textLabel.textColor = .white
            textLabel.textAlignment = .center
            textLabel.font = .systemFont(ofSize: 10)
            textLabel.backgroundColor = .lightGray
            textLabel.layer.masksToBounds = true
            textLabel.layer.cornerRadius = frame.size.width / 2
            view.addSubview(textLabel)
            
            // 右上角的[跳过按钮]
            let button = UIProgressCircle(frame: frame, mode: .timer) // 36x36
            button.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
            button.duration = 5
            button.nnTitle = "跳过"
            button.nnTitleColor = .white
            //button.textLabel.text = "跳过"
            //button.textLabel.textColor = UIColor.white
            //button.textLabel.backgroundColor = UIColor.lightGray
            button.addTarget(self, action: #selector(leaveButtonChanged), for: .valueChanged)
            button.addTarget(self, action: #selector(leaveButtonPressed), for: .touchUpInside)
            view.addSubview(button)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 如果显示的是启动图, 定时2s后退出本页面
        if state == .default {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.delegate.launchController?(self, autoLeave: 0)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UILaunchImageCell.defaultIdentifier, for: indexPath) as! UILaunchImageCell
        cell.imageView.image = images[indexPath.row]
        cell.button.isHidden = (state != .install) || (indexPath.row != images.count - 1)
        cell.button.addTarget(self, action: #selector(leaveButtonPressed), for: .touchUpInside)
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = ceil(scrollView.contentOffsetX / scrollView.width).asInt
    }
    
    @objc func leaveButtonChanged() {
        delegate.launchController?(self, autoLeave: 0)
    }
    
    @objc func leaveButtonPressed() {
        delegate.launchController?(self, skipPage: 0)
    }
    
    /// 需要在外部(通过联网)获得预加载图片, 将他们按顺序设置到本方法中
    func setPreloadImages(_ images: [UIImage]) {
        
        var relativePaths = [String]()
        
        for (index, image) in images.enumerated() {
            
            let relativePath = String(format: "/PreloadImages-%d.png", index)
            relativePaths.append(relativePath)
            
            let localURL = Bundle.documentDirectory.appending(relativePath).asFileURL
            try? image.pngData()?.write(to: localURL)
        }
        
        UserDefaults.standard.set(relativePaths, forKey: kPreloadImages)
    }
    
    /// 清理掉预加载图片
    func clearPreloadImages() {
        
        guard let relativePaths = UserDefaults.standard.array(forKey: kPreloadImages) as? [String] else {
            return
        }
        
        for relativePath in relativePaths {
            let absolutePath = Bundle.documentDirectory.appendingFormat("/%@", relativePath)
            try? FileManager.default.removeItem(atPath: absolutePath)
        }
        
        UserDefaults.standard.removeObject(forKey: kPreloadImages)
    }
    
    /// [初次安装]或者[版本更新]后, 第一次启动本程序
    private func isInstalledOrUpdated() -> Bool {
        let lastVersion = UserDefaults.standard.string(forKey: kPreloadVersion)
        if lastVersion == nil { return true }
        if lastVersion != Bundle.shortVersion { return true }
        return false
    }
    
    /// 将要轮播的图片
    private func scrollImages() -> [UIImage] {
        
        if isInstalledOrUpdated() {
            state = .install
            UserDefaults.standard.set(Bundle.shortVersion, forKey: kPreloadVersion)
            return installImages()
        }
        
        let aImages = preloadImages()
        if aImages.count > 0 {
            state = .preload
            return aImages
        }
        
        state = .default
        if let image = UIImage.launchImage() {
            return [image]
        }
        
        fatalError("既不是刚刚更新, 又没有预加载, 还没有从启动页中找到符合当前屏幕的图片, 肯定是哪里有问题")
    }
    
    /// 从mainBundle中取得当前版本自带的介绍图, 需要开发者将图片以固定名称LaunchImage-x的形式, 将图片放入到项目中
    private func installImages() -> [UIImage] {
        
        var images = [UIImage]()
        
        for idx in 0...2 {
        
            if let image = UIImage(named: "Assets/LaunchImage-\(idx)") {
                images.append(image)
            }
            else {
                fatalError("缺少图片`Assets/LaunchImage-\(idx).png`")
            }
        }
        
        return images
    }
    
    /// 从document中取得预加载的广告图片. 需要开发者使用其他方式获得广告图, 将它们按顺序更新到kPreloadImages中去
    private func preloadImages() -> [UIImage] {
        
        guard let relativePaths = UserDefaults.standard.array(forKey: kPreloadImages) as? [String] else {
            return []
        }
        
        let sorted = relativePaths.sorted { $0 > $1 }
        
        return sorted.map {
            let imagePath = Bundle.documentDirectory.appendingFormat("/%@", $0)
            return UIImage(contentsOfFile: imagePath)!
        }
    }
}


class UILaunchImageCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    /// 最后一张图片上的[完成按钮]
    let button = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        backgroundView = imageView
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(hexInteger: 0xffffff, alpha: 0.9)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.nnTitle = "立即进入"
        button.nnTitleColor = .darkGray
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        contentView.addSubview(button)
        
        button.lcCenterX *= contentView.lcCenterX
        button.lcBottom *= contentView.lcBottom *- 80
        button.lcWidth *= 160
        button.lcHeight *= 40
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


@objc protocol UILaunchControllerDelegate : NSObjectProtocol {
    
    @objc optional func launchController(_ sender: UILaunchController, skipPage unused: Int)
    
    @objc optional func launchController(_ sender: UILaunchController, autoLeave unused: Int)
}
