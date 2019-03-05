//
//  UIImageShowerController.swift
//  Library
//
//  Created by weizhen on 2018/2/28.
//  Copyright © 2018年 Wuhan Mengxin Technology Co., Ltd. All rights reserved.
//

import UIKit

class UIImageShowerController: UIViewController, UIScrollViewDelegate {

    let navigationBar = UINavigationBar()
    
    let scrollView = UIScrollView()
    
    let pageControl = UIPageControl()
    
    var imageViews = [UIImageViewEx]()
    
    var originalFrame = CGRect.zero
    
    init(images: [UIImage], titles: [String], currentIndex: Int) {
        super.init(nibName: nil, bundle: nil)
        
        for index in 0 ..< images.count {
            let imageView = UIImageViewEx(frame: .zero)
            imageView.image = images[index]
            imageView.title = titles[index]
            imageViews.append(imageView)
        }
        
        pageControl.numberOfPages = self.imageViews.count
        pageControl.currentPage = currentIndex
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .darkGray
        
        let navigationItem = UINavigationItem()
        
        let returnButton = UIButton(frame: CGRectMake(0, 0, 54, 44))
        returnButton.nnTitle = "返回"
        returnButton.nnTitleColor = .white
        returnButton.nhTitleColor = .green
        returnButton.addTarget(self, action: #selector(returnPressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: returnButton)

        navigationBar.setBackgroundImage(UIImage(named: "bg111"), for: .default)
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]
        navigationBar.isTranslucent = true
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.pushItem(navigationItem, animated: false)
        view.addSubview(navigationBar)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = true
        view.addSubview(scrollView)
        view.sendSubviewToBack(scrollView)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.hidesForSinglePage = true
        pageControl.isEnabled = false
        view.addSubview(pageControl)
        
        for imageView in imageViews {
            scrollView.addSubview(imageView)
            imageView.recognizerForPin.addTarget(self, action: #selector(recognizerForPin(_:)))
            imageView.recognizerForPan.addTarget(self, action: #selector(recognizerForPan(_:)))
            imageView.recognizerForTap.addTarget(self, action: #selector(recognizerForTap(_:)))
            imageView.recognizerForTwo.addTarget(self, action: #selector(recognizerForTwo(_:)))
        }
        
        NSLayoutConstraint.constraints(withVisualFormat: "V:|[navigationBar(64)]",  options: [], metrics: nil, views: ["navigationBar": navigationBar])
        NSLayoutConstraint.constraints(withVisualFormat: "H:|[navigationBar]|",     options: [], metrics: nil, views: ["navigationBar": navigationBar])
        NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|",        options: [], metrics: nil, views: ["scrollView": scrollView])
        NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|",        options: [], metrics: nil, views: ["scrollView": scrollView])
        NSLayoutConstraint.constraints(withVisualFormat: "V:[pageControl(40)]|",    options: [], metrics: nil, views: ["pageControl": pageControl])
        NSLayoutConstraint.constraints(withVisualFormat: "H:|[pageControl]|",       options: [], metrics: nil, views: ["pageControl": pageControl])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layoutImageViews()
    }
    
    @objc func returnPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    func layoutImageViews() {
        
        let rectW = self.view.bounds.size.width
        let rectH = self.view.bounds.size.height
        let rectX = self.view.center.x
        let rectY = self.view.center.y
        
        self.scrollView.contentSize = CGSizeMake(rectW * self.imageViews.count, rectH)
        self.scrollView.contentOffset = CGPointMake(rectW * self.pageControl.currentPage, 0)
        
        for (idx, imageView) in imageViews.enumerated() {
            
            let offset = rectW * idx
            var imageW = imageView.image!.size.width
            var imageH = imageView.image!.size.height
            
            if (imageW > rectW || imageH > rectH) {
                
                if (imageW / imageH > rectW / rectH) {
                    imageH = imageH * rectW / imageW
                    imageW = rectW
                }
                else {
                    imageW = imageW * rectH / imageH
                    imageH = rectH
                }
            }
            
            imageView.center = CGPointMake(rectX + offset, rectY)
            imageView.bounds = CGRectMake(0, 0, imageW, imageH)
        }
    }
    
    func setImageView(_ imageView: UIImageViewEx, editing: Bool) {
        
        if (editing) {
            isEditing = true
            scrollView.isScrollEnabled = false
            originalFrame = imageView.frame
            imageView.recognizerForPin.isEnabled = true
            imageView.recognizerForPan.isEnabled = true
            imageView.recognizerForTap.isEnabled = true
            imageView.recognizerForTwo.isEnabled = true
        }
        else {
            isEditing = false
            scrollView.isScrollEnabled = true
            imageView.frame = self.originalFrame
            imageView.recognizerForPin.isEnabled = true
            imageView.recognizerForPan.isEnabled = false
            imageView.recognizerForTap.isEnabled = true
            imageView.recognizerForTwo.isEnabled = false
        }
    }
    
    @objc func recognizerForPin(_ recognizer: UIPinchGestureRecognizer) {
        
        let imageView = recognizer.view as! UIImageViewEx
        
        if (self.isEditing == false) {
            if (recognizer.scale > 1.0) {
                setImageView(imageView, editing: true)
            }
            recognizer.scale = 1.0
            return
        }
        
        let scrollBoundsW = self.scrollView.bounds.size.width
        let scrollBoundsH = self.scrollView.bounds.size.height
        let scrollCenterX = scrollBoundsW / 2 + self.pageControl.currentPage * scrollBoundsW
        let scrollCenterY = scrollBoundsH / 2
        var centerX = imageView.center.x
        var centerY = imageView.center.y
        var boundsW = imageView.bounds.size.width + (recognizer.scale - 1.0) * 1000
        
        if (boundsW < self.originalFrame.size.width) {
            setImageView(imageView, editing: false)
            recognizer.scale = 1.0
            return;
        }
        
        if (boundsW > imageView.image!.size.width) {
            boundsW = imageView.image!.size.width
        }
        
        let boundsH = boundsW * imageView.bounds.size.height / imageView.bounds.size.width
        
        if (boundsW > scrollBoundsW) {
            
            if (centerX - boundsW / 2 > scrollCenterX - scrollBoundsW / 2) {
                centerX = scrollCenterX - scrollBoundsW / 2 + boundsW / 2
            }
            
            if (centerX + boundsW / 2 < scrollCenterX + scrollBoundsW / 2) {
                centerX = scrollCenterX + scrollBoundsW / 2 - boundsW / 2
            }
        }
        else {
            centerX = scrollCenterX
        }
        
        if (boundsH > scrollBoundsH) {
            if (centerY - boundsH / 2 > scrollCenterY - scrollBoundsH / 2) {
                centerY = scrollCenterY - scrollBoundsH / 2 + boundsH / 2
            }
            
            if (centerY + boundsH / 2 < scrollCenterY + scrollBoundsH / 2) {
                centerY = scrollCenterY + scrollBoundsH / 2 - boundsH / 2
            }
        }
        else {
            centerY = scrollCenterY
        }
        
        imageView.center = CGPointMake(centerX, centerY)
        imageView.bounds = CGRectMake(0, 0, boundsW, boundsH)
        
        recognizer.scale = 1.0
    }
    
    @objc func recognizerForPan(_ recognizer: UIPanGestureRecognizer) {
        
        let imageView = recognizer.view as! UIImageViewEx
        
        let offset = recognizer.translation(in: imageView)
        
        let scrollBoundsW = self.scrollView.bounds.size.width
        let scrollBoundsH = self.scrollView.bounds.size.height
        let scrollCenterX = scrollBoundsW / 2 + self.pageControl.currentPage * scrollBoundsW
        let scrollCenterY = scrollBoundsH / 2
        let boundsW = imageView.bounds.size.width
        let boundsH = imageView.bounds.size.height
        var centerX = imageView.center.x + offset.x
        var centerY = imageView.center.y + offset.y
        
        if (boundsW > scrollBoundsW) {
            
            if (centerX - boundsW / 2 > scrollCenterX - scrollBoundsW / 2) {
                centerX = scrollCenterX - scrollBoundsW / 2 + boundsW / 2
            }
            
            if (centerX + boundsW / 2 < scrollCenterX + scrollBoundsW / 2) {
                centerX = scrollCenterX + scrollBoundsW / 2 - boundsW / 2
            }
        }
        else {
            centerX = scrollCenterX
        }
        
        if (boundsH > scrollBoundsH) {
            if (centerY - boundsH / 2 > scrollCenterY - scrollBoundsH / 2) {
                centerY = scrollCenterY - scrollBoundsH / 2 + boundsH / 2
            }
            
            if (centerY + boundsH / 2 < scrollCenterY + scrollBoundsH / 2) {
                centerY = scrollCenterY + scrollBoundsH / 2 - boundsH / 2
            }
        }
        else {
            centerY = scrollCenterY
        }
        
        imageView.center = CGPointMake(centerX, centerY)
        imageView.bounds = CGRectMake(0, 0, boundsW, boundsH)
        
        recognizer.setTranslation(.zero, in: imageView)
    }
    
    @objc func recognizerForTap(_ recognizer: UITapGestureRecognizer) {
        navigationBar.isHidden = !navigationBar.isHidden
    }
    
    @objc func recognizerForTwo(_ recognizer: UITapGestureRecognizer) {
        let imageView = recognizer.view as! UIImageViewEx
        setImageView(imageView, editing: false)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        
        let imageView = imageViews[pageControl.currentPage]
        navigationBar.items?.first?.title = imageView.title
    }
}

class UIImageViewEx: UIImageView {
    
    let recognizerForPin = UIPinchGestureRecognizer()
    
    let recognizerForPan = UIPanGestureRecognizer()
    
    let recognizerForTap = UITapGestureRecognizer()
    
    let recognizerForTwo = UITapGestureRecognizer()
    
    var title : String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = true
        
        recognizerForPin.isEnabled = true
        addGestureRecognizer(recognizerForPin)

        recognizerForPan.isEnabled = true
        addGestureRecognizer(recognizerForPan)
        
        recognizerForTap.isEnabled = true
        addGestureRecognizer(recognizerForTap)
        
        recognizerForTwo.numberOfTapsRequired = 2
        recognizerForTwo.isEnabled = true
        addGestureRecognizer(recognizerForTwo)
        
        recognizerForTap.require(toFail: recognizerForTwo)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

