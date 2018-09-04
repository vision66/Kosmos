//
//  UITextImageButton.swift
//  novel
//
//  Created by weizhen on 2017/9/6.
//  Copyright © 2017年 Wuhan Mengxin Technology Co., Ltd. All rights reserved.
//

import UIKit

class UITextImageButton: UIControl {
    
    let imageView = UIImageView()
    
    let textLabel = UILabel()
    
    let textPosition : UIViewContentMode
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /** style: 文本相对于图片的位置 */
    init(frame: CGRect, style: UIViewContentMode) {
        
        self.textPosition = style
        
        super.init(frame: frame)
        
        imageView.bounds = CGRectMake(0, 0, 20, 20)
        self.addSubview(imageView)
        
        self.addSubview(textLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    override func layoutSubviews() {
        
        let sfw = self.bounds.size.width
        let sfh = self.bounds.size.height
        let ivw = self.imageView.bounds.size.width
        let ivh = self.imageView.bounds.size.height
        
        if self.textPosition == .top {
            let tlw = sfw
            let tlh = sfh - ivh
            self.textLabel.frame = CGRectMake(0, 0, tlw, tlh)
            self.imageView.frame = CGRectMake(sfw/2-ivw/2, tlh, ivw, ivh)
            return
        }
        
        if self.textPosition == .bottom {
            let tlw = sfw
            let tlh = sfh - ivh
            self.textLabel.frame = CGRectMake(0, ivh, tlw, tlh)
            self.imageView.frame = CGRectMake(sfw/2-ivw/2, 0, ivw, ivh)
            return
        }
        
        if self.textPosition == .left {
            let tlw = sfw - ivw
            let tlh = sfh
            self.textLabel.frame = CGRectMake(0, 0, tlw, tlh)
            self.imageView.frame = CGRectMake(sfw-ivw, sfh/2-ivh/2, ivw, ivh)
            return
        }
        
        if self.textPosition == .right {
            let tlw = sfw - ivw
            let tlh = sfh
            self.textLabel.frame = CGRectMake(ivw, 0, tlw, tlh)
            self.imageView.frame = CGRectMake(0, sfh/2-ivh/2, ivw, ivh)
            return
        }
    }
    
    @objc
    private func handleTap(_ recognizer: UITapGestureRecognizer) {
        self.sendActions(for: .touchUpInside)
    }
    
    func setImageSize(_ size: CGSize) {
        self.imageView.bounds = CGRectMake(0, 0, size.width, size.height)
    }
    
    var text : String? {
        get { return self.textLabel.text }
        set { self.textLabel.text = newValue }
    }
}
