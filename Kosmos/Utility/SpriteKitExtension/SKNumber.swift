//
//  SKNumber.swift
//  number
//
//  Created by weizhen on 2018/11/6.
//  Copyright © 2018 Wuhan Mengxin Technology Co., Ltd. All rights reserved.
//

import SpriteKit

/// ```
/// let numberNode = SKNumber(texture: nil, color: UIColor.clear, size: CGSize(width: 600, height: 40))
/// numberNode.position = CGPoint.zero
/// numberNode.baseTexture = atlas.first!.textureNamed("number_earth")
/// self.addChild(numberNode)
/// self.numberNode = numberNode
///
/// numberNode?.setNumber(currentNumber)
/// numberNode?.run(SKAction.sequence([SKAction.scale(to: 1.2, duration: 0.2), SKAction.scale(to: 1.0, duration: 0.2)]))
/// ```
class SKNumber: SKSpriteNode {
    
    /// 当前的数值
    private(set) var number : Int = 0
    
    /// 素材
    var baseTexture : SKTexture!
    
    /// 动画切换帧数
    var animateFrame : Int = 20
    
    /// 动画持续时间
    var animateDuration : TimeInterval = 0.4
    
    /// init
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    /// init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// 将数值调整为number, 自身的size会因为baseTexture的尺寸而变化
    ///
    /// - Parameters:
    ///   - number: 将数值调整为number
    ///   - animated: 是否有动画效果, 动画将在animateDuration秒内完成
    func setNumber(_ number: Int, animated: Bool = true) {
        
        if animated {
            let delta = Float(number - self.number) / Float(animateFrame)
            var textures = [SKTexture]()
            for index in 0 ..< animateFrame {
                if index == animateFrame - 1 {
                    let image = generateImage(from: number)
                    let texture = SKTexture(image: image)
                    textures.append(texture)
                    
                } else {
                    let num = floor(Float(self.number) + delta * Float(index))
                    let image = generateImage(from: Int(num))
                    let texture = SKTexture(image: image)
                    textures.append(texture)
                }
            }
            run(SKAction.animate(with: textures, timePerFrame: animateDuration / Double(animateFrame), resize: true, restore: false))
        }
        else {
            let image = generateImage(from: number)
            self.texture = SKTexture(image: image)
            self.size = image.size
        }
        
        self.number = number
    }
    
    /// 将数值转化为图片
    func generateImage(from number: Int) -> UIImage {
        
        // 依次从number的个位开始, 将图片保存到其中
        var parts = [CGImage]()
        
        //
        let baseImage = baseTexture.cgImage()
        let partWidth = baseImage.width / 10
        let partHeight = baseImage.height
        
        // 被处理的数值
        var result = number
        
        if number == 0 {
            
            let rect = CGRect(x: 0, y: 0, width: partWidth, height: partHeight)
            
            let part = baseImage.cropping(to: rect)!
            
            parts.append(part)
        }
        else {
            
            while result > 0 {
                
                let num = result % 10
                
                let rect = CGRect(x: partWidth * num, y: 0, width: partWidth, height: partHeight)
                
                let part = baseImage.cropping(to: rect)!
                
                parts.append(part)
                
                result = result / 10
            }
        }
        
        // 构造新的image
        let scale : CGFloat = 2.0
        let scaleWidth = CGFloat(partWidth) / scale
        let scaleHeight = CGFloat(partHeight) / scale
        let size = CGSize(width: CGFloat(parts.count) * scaleWidth, height: scaleHeight)
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        for (index, part) in parts.reversed().enumerated() {
            UIImage(cgImage: part).draw(in: CGRect(x: CGFloat(index) * scaleWidth, y: 0, width: scaleWidth, height: scaleHeight))
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
