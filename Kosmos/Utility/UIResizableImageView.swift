//
//  UIResizableImageView.swift
//  novel
//
//  Created by weizhen on 2017/9/6.
//  Copyright © 2017年 weizhen. All rights reserved.
//

import UIKit

class UIResizableImageView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, leftImage: UIImage, rightImage: UIImage) {
        super.init(frame: frame)
        
        let part1 = UIImageView()
        part1.translatesAutoresizingMaskIntoConstraints = false
        part1.image = leftImage
        self.addSubview(part1)
        
        let part2 = UIImageView()
        part2.translatesAutoresizingMaskIntoConstraints = false
        part2.image = rightImage
        self.addSubview(part2)
        
        part1.lcAllButRight *= self.lcAllButRight
        part1.lcRight *= part2.lcLeft
        part2.lcAllButLeft *= self.lcAllButLeft
        part2.lcWidth *= part1.lcWidth
    }
}
