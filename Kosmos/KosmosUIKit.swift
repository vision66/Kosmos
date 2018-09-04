//
//  NSLayoutConstraintHelper.swift
//  NSLayoutConstraintHelper
//
//  Created by weizhen on 16/8/1.
//

import UIKit

extension UIColor {
    
    convenience init(hexInteger: Int, alpha: CGFloat = 1.0) {
        self.init(red: ((hexInteger >> 16) & 0xFF) / 255.0, green:((hexInteger >> 8) & 0xFF) / 255.0, blue:((hexInteger) & 0xFF) / 255.0, alpha:alpha)
    }
}

extension UIFont {
    
    static func monsopacedFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica Neue", size: fontSize)!
    }
    
    static func allFontFamilys() {        
        for familyName in UIFont.familyNames {
            print(familyName)
            let fontNames = UIFont.fontNames(forFamilyName: familyName)
            for fontName in fontNames {
                print("\t \(fontName)")
            }
        }
    }
}

extension UIImage {
    
    /// 从Assets目录加载图片
    convenience init?(asset: String) {
        self.init(named: "Assets/" + asset)
    }
    
    /// 将图片拉伸, 以填满区域. 图片可能会变形
    func scaleToFill(toSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        draw(in: CGRectMake(0, 0, size.width, size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 将图片拉伸, 以填满区域. 图片既不会变形, 也没有裁剪
    func scaleAspectFit(toSize size: CGSize) -> UIImage {
        let rate = self.size.width / self.size.height
        let comp = (size.width / size.height > rate)
        let newW = comp ? size.height * rate : size.width
        let newH = comp ? size.height : size.width / rate        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(newW, newH), false, UIScreen.main.scale)
        draw(in: CGRectMake(0, 0, newW, newH))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 将图片拉伸, 以填满区域. 图片可能会裁剪
    func scaleAspectFill(toSize size: CGSize) -> UIImage {
        
        let sourceSize = self.size
        let targetSize = size
        
        var thumbnailX = 0 as CGFloat
        var thumbnailY = 0 as CGFloat
        var thumbnailW = targetSize.width
        var thumbnailH = targetSize.height

        if __CGSizeEqualToSize(sourceSize, targetSize) == false {
            
            // thumbnail factor
            let factorW = targetSize.width / sourceSize.width
            let factorH = targetSize.height / sourceSize.height
            let factor = (factorW > factorH) ? factorW : factorH
            
            // thumbnail size
            thumbnailW = sourceSize.width * factor
            thumbnailH = sourceSize.height * factor
            
            // center the image
            if factorW > factorH {
                thumbnailY = (targetSize.height - thumbnailH) * 0.5
            } else if factorW < factorH {
                thumbnailX = (targetSize.width - thumbnailW) * 0.5
            }
        }
        
        let thumbnailRect = CGRectMake(thumbnailX, thumbnailY, thumbnailW, thumbnailH)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, UIScreen.main.scale)
        self.draw(in: thumbnailRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 压缩图片到适合大小, 然后将图片数据(JPG格式)输出
    var jpgData : Data {
        
        var curCompression = 0.9 as CGFloat
        let maxCompression = 0.1 as CGFloat
        let maxFileSize = 100 * 1024
        
        let sourceImage = self
        
        var imageData = UIImageJPEGRepresentation(sourceImage, curCompression)!
        
        while imageData.count > maxFileSize && curCompression > maxCompression {
            curCompression -= 0.1
            imageData = UIImageJPEGRepresentation(sourceImage, curCompression)!
        }
        
        return imageData
    }
    
    /// 输出PNG格式的图片数据
    var pngData : Data {
        return UIImagePNGRepresentation(self)!
    }
    
    /// 生成纯色组成的图片
    static func imageWithColor(_ color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(CGRectMake(0, 0, size.width, size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// 给当前图片混合颜色
    func imageWithBlendColor(_ color: UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        context.clip(to: rect, mask: cgImage!)
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// 生成圆角图片
    func imageWithCorner(_ cornerRadius: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRectMake(0, 0, self.size.width, self.size.height)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        path.addClip()
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// 生成圆形图片
    var circleImage : UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        let rect = CGRectMake(0, 0, self.size.width, self.size.height)
        context.addEllipse(in: rect)
        context.clip()
        context.draw(self.cgImage!, in: rect)
        //CGContextSetLineWidth(context, 4);
        //CGContextSetLineColorWithHex(context, 0x00FF00, 1.0);
        //CGContextStrokePath(context);
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// 生成灰色图片
    var grayImage : UIImage? {
        
        let w = self.size.width
        let h = self.size.height
        
        let colorSpace = CGColorSpaceCreateDeviceGray()
        
        // CGBitmapContextCreate, kCGBitmapByteOrderDefault
        guard let context = CGContext(data: nil, width: Int(w), height: Int(h), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: 0) else {
            return nil
        }
        
        context.draw(self.cgImage!, in: CGRectMake(0, 0, w, h))
        
        guard let cgImage = context.makeImage() else {
            return nil
        }
        
        let newImage = UIImage(cgImage: cgImage)
        
        return newImage
    }
    
    /// 生成RGBA格式的Data
    var rgbaData : Data {
        
        guard let imageRef = self.cgImage else {
            fatalError("If the UIImage object was initialized using a CIImage object, the value of the property is NULL.")
        }
        
        let bitsPerPixel = 32
        let bitsPerComponent = 8
        let bytesPerPixel = bitsPerPixel / bitsPerComponent
        
        let width = imageRef.width
        let height = imageRef.height
        
        let bytesPerRow = width * bytesPerPixel
        let bytesOfAll = bytesPerRow * height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            fatalError("Create context failed!")
        }
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        context.draw(imageRef, in: rect)
        
        // Get a pointer to the data
        let data = Data(bytes: context.data!, count: bytesOfAll)
        
        return data
    }
    
    /// 生成电量图标(深色)
    static func darkBattery(by power: CGFloat) -> UIImage {
        let value = (power >= 0 && power <= 100) ? power : 0
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 24, height: 12), false, 2)
        UIImage(asset: "battery_shell_dark")!.draw(in: CGRect(x: 0, y: 0, width: 24, height: 12))
        UIImage(asset: "battery_content_dark")!.draw(in: CGRect(x: 3, y: 3, width: 16 * value, height: 6))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 生成电量图标(浅色)
    static func lightBattery(by power: CGFloat) -> UIImage {
        let value = (power >= 0 && power <= 100) ? power : 0
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 24, height: 12), false, 2)
        UIImage(asset: "battery_shell_light")!.draw(in: CGRect(x: 0, y: 0, width: 24, height: 12))
        UIImage(asset: "battery_content_light")!.draw(in: CGRect(x: 3, y: 3, width: 16 * value, height: 6))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }    
}

extension UIView {
    
    /// 取得当前快照(UIImage类型)
    var snapshot : UIImage {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 取得与自己最近的视图控制器
    var viewController : UIViewController? {
        
        var responder : UIResponder? = self
        
        repeat {
        
            responder = responder?.next
            
            if let viewController = responder as? UIViewController {
                return viewController
            }
            
        } while responder != nil
        
        return nil
    }
    
    var left : CGFloat {
        set { self.frame = CGRectMake(newValue, frame.origin.y, frame.size.width, frame.size.height) }
        get { return frame.origin.x }
    }
    
    var right : CGFloat {
        set { self.frame = CGRectMake(frame.origin.x, frame.origin.y, newValue - frame.origin.x, frame.size.height) }
        get { return frame.origin.x + frame.size.width }
    }
    
    var top : CGFloat {
        set { self.frame = CGRectMake(frame.origin.x, newValue, frame.size.width, frame.size.height) }
        get { return frame.origin.y }
    }
    
    var bottom : CGFloat {
        set { self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, newValue - frame.origin.y) }
        get { return frame.origin.y + frame.size.height }
    }
    
    var width : CGFloat {
        set { self.frame = CGRectMake(frame.origin.x, frame.origin.y, newValue, frame.size.height) }
        get { return frame.size.width }
    }
    
    var height : CGFloat {
        set { self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, newValue) }
        get { return frame.size.height }
    }
    
    var topLeft : CGPoint {
        set { self.frame = CGRectMake(newValue.x, newValue.y, frame.size.width, frame.size.height) }
        get { return frame.origin }
    }
    
    var rightBottom : CGPoint {
        set { self.frame = CGRectMake(frame.origin.x, frame.origin.y, newValue.x - frame.origin.x, newValue.y - frame.origin.y) }
        get { return CGPointMake(frame.origin.x + frame.size.width, frame.origin.y + frame.size.height) }
    }
    
    var size : CGSize {
        set { self.frame = CGRectMake(frame.origin.x, frame.origin.y, newValue.width, newValue.height) }
        get { return frame.size }
    }
    
    var asLabel : UILabel? {
        return self as? UILabel
    }
}

extension UIScrollView {
    
    var contentOffsetX: CGFloat {
        set { self.contentOffset = CGPointMake(newValue, self.contentOffset.y) }
        get { return self.contentOffset.x }
    }
    
    var contentOffsetY: CGFloat {
        set { self.contentOffset = CGPointMake(self.contentOffset.x, newValue) }
        get { return self.contentOffset.y }
    }
}

extension UIButton {
    
    /// 设置普通文字
    var nnTitle : String? {
        set { self.setTitle(newValue, for: .normal) }
        get { return self.title(for: .normal) }
    }
    
    /// 设置高亮文字
    var nhTitle : String? {
        set { self.setTitle(newValue, for: .highlighted) }
        get { return self.title(for: .highlighted) }
    }
    
    /// 设置禁用文字
    var ndTitle : String? {
        set { self.setTitle(newValue, for: .disabled) }
        get { return self.title(for: .disabled) }
    }
    
    /// 设置选中时的普通文字
    var snTitle : String? {
        set { self.setTitle(newValue, for: UIControlState.selected.union(.normal)) }
        get { return self.title(for: UIControlState.selected.union(.normal)) }
    }
    
    /// 设置选中时的高亮文字
    var shTitle : String? {
        set { self.setTitle(newValue, for: UIControlState.selected.union(.highlighted)) }
        get { return self.title(for: UIControlState.selected.union(.highlighted)) }
    }
    
    /// 设置选中时的禁用文字
    var sdTitle : String? {
        set { self.setTitle(newValue, for: UIControlState.selected.union(.disabled)) }
        get { return self.title(for: UIControlState.selected.union(.disabled)) }
    }
    
    /// 设置普通文字颜色
    var nnTitleColor : UIColor? {
        set { self.setTitleColor(newValue, for: .normal) }
        get { return self.titleColor(for: .normal) }
    }
    
    /// 设置高亮文字颜色
    var nhTitleColor : UIColor? {
        set { self.setTitleColor(newValue, for: .highlighted) }
        get { return self.titleColor(for: .highlighted) }
    }
    
    /// 设置禁用文字颜色
    var ndTitleColor : UIColor? {
        set { self.setTitleColor(newValue, for: .disabled) }
        get { return self.titleColor(for: .disabled) }
    }
    
    /// 设置选中时的普通文字颜色
    var snTitleColor : UIColor? {
        set { self.setTitleColor(newValue, for: UIControlState.selected.union(.normal)) }
        get { return self.titleColor(for: UIControlState.selected.union(.normal)) }
    }
    
    /// 设置选中时的高亮文字颜色
    var shTitleColor : UIColor? {
        set { self.setTitleColor(newValue, for: UIControlState.selected.union(.highlighted)) }
        get { return self.titleColor(for: UIControlState.selected.union(.highlighted)) }
    }
    
    /// 设置选中时的禁用文字
    var sdTitleColor : UIColor? {
        set { self.setTitleColor(newValue, for: UIControlState.selected.union(.disabled)) }
        get { return self.titleColor(for: UIControlState.selected.union(.disabled)) }
    }
    
    /// 设置普通图片
    var nnImage : UIImage? {
        set { self.setImage(newValue, for: .normal) }
        get { return self.image(for: .normal) }
    }
    
    /// 设置高亮图片
    var nhImage : UIImage? {
        set { self.setImage(newValue, for: .highlighted) }
        get { return self.image(for: .highlighted) }
    }
    
    /// 设置禁用图片
    var ndImage : UIImage? {
        set { self.setImage(newValue, for: .disabled) }
        get { return self.image(for: .disabled) }
    }
    
    /// 设置选中时的普通图片
    var snImage : UIImage? {
        set { self.setImage(newValue, for: UIControlState.selected.union(.normal)) }
        get { return self.image(for: UIControlState.selected.union(.normal)) }
    }
    
    /// 设置选中时的高亮图片
    var shImage : UIImage? {
        set { self.setImage(newValue, for: UIControlState.selected.union(.highlighted)) }
        get { return self.image(for: UIControlState.selected.union(.highlighted)) }
    }
    
    /// 设置选中时的禁用图片
    var sdImage : UIImage? {
        set { self.setImage(newValue, for: UIControlState.selected.union(.disabled)) }
        get { return self.image(for: UIControlState.selected.union(.disabled)) }
    }
    
    /// 设置普通背景
    var nnBackgroundImage : UIImage? {
        set { self.setBackgroundImage(newValue, for: .normal) }
        get { return self.backgroundImage(for: .normal) }
    }
    
    /// 设置高亮背景
    var nhBackgroundImage : UIImage? {
        set { self.setBackgroundImage(newValue, for: .highlighted) }
        get { return self.backgroundImage(for: .highlighted) }
    }
    
    /// 设置禁用背景
    var ndBackgroundImage : UIImage? {
        set { self.setBackgroundImage(newValue, for: .disabled) }
        get { return self.backgroundImage(for: .disabled) }
    }
    
    /// 设置选中时的普通背景
    var snBackgroundImage : UIImage? {
        set { self.setBackgroundImage(newValue, for: UIControlState.selected.union(.normal)) }
        get { return self.backgroundImage(for: UIControlState.selected.union(.normal)) }
    }
    
    /// 设置选中时的高亮背景
    var shBackgroundImage : UIImage? {
        set { self.setBackgroundImage(newValue, for: UIControlState.selected.union(.highlighted)) }
        get { return self.backgroundImage(for: UIControlState.selected.union(.highlighted)) }
    }
    
    /// 设置选中时的禁用背景
    var sdBackgroundImage : UIImage? {
        set { self.setBackgroundImage(newValue, for: UIControlState.selected.union(.disabled)) }
        get { return self.backgroundImage(for: UIControlState.selected.union(.disabled)) }
    }
    
    /// 使用其他按钮的风格进行配置
    var sameto : UIButton {
        set {
            self.layer.borderWidth = newValue.layer.borderWidth
            self.layer.borderColor = newValue.layer.borderColor
            self.layer.cornerRadius = newValue.layer.cornerRadius
            self.layer.masksToBounds = newValue.layer.masksToBounds
            self.nnTitleColor = newValue.nnTitleColor
            self.snTitleColor = newValue.snTitleColor
            self.titleLabel?.font = newValue.titleLabel?.font
            self.titleEdgeInsets = newValue.titleEdgeInsets
            self.imageEdgeInsets = newValue.imageEdgeInsets
            self.contentEdgeInsets = newValue.contentEdgeInsets
            self.backgroundColor = newValue.backgroundColor
            self.contentVerticalAlignment = newValue.contentVerticalAlignment
            self.contentHorizontalAlignment = newValue.contentHorizontalAlignment
        }
        get {
            return self
        }
    }
    
    //枚举图片的位置
    enum ButtonImageEdgeInsetsStyle {
        case top    //上图下文字
        case left   //左图右文字
        case bottom //下图上文字
        case right  //右图左文字
    }
    
    // style:图片位置 space:图片与文字的距离
    func layoutButtonImageEdgeInsetsStyle(style: ButtonImageEdgeInsetsStyle, space: CGFloat) {
        
        let imageWidth : CGFloat = (imageView?.frame.size.width)!
        let imageHeight : CGFloat = (imageView?.frame.size.height)!
        
        let labelWidth = (titleLabel?.intrinsicContentSize.width)!
        let labelHeight = (titleLabel?.intrinsicContentSize.height)!
        
        switch style {
        case .top:
            imageEdgeInsets = UIEdgeInsetsMake(-labelHeight-space/2.0, 0, 0, -labelWidth)
            titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, -imageHeight-space/2.0, 0)
        case .left:
            imageEdgeInsets = UIEdgeInsetsMake(0, -space/2.0, 0, space/2.0)
            titleEdgeInsets = UIEdgeInsetsMake(0, space/2.0, 0, -space/2.0)
        case .bottom:
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight-space/2.0, -labelWidth)
            titleEdgeInsets = UIEdgeInsetsMake(-imageHeight-space/2.0, -imageWidth, 0, 0)
        case .right:
            imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth+space/2.0, 0, -labelWidth-space/2.0)
            titleEdgeInsets = UIEdgeInsetsMake(0, -labelWidth-space/2.0, 0, labelWidth+space/2.0)
        }
    }
}

extension UITableView {
    
    var backgroundLabel: UILabel? {
        set { self.backgroundView = newValue }
        get { return self.backgroundView as? UILabel }
    }

    var messageWhenNoItem: NSAttributedString? {
        
        set {
            if let label = self.backgroundLabel {
                label.attributedText = newValue
            } else {
                let label = UILabel()
                label.font = .systemFont(ofSize: 16)
                label.textAlignment = .center
                label.textColor = UIColor.darkGray
                label.isHidden = true
                label.numberOfLines = 0
                label.attributedText = newValue
                self.backgroundView = label
            }
        }
        
        get {
            return self.backgroundLabel?.attributedText
        }
    }
}

extension UITableViewCell {
    
    static var defaultIdentifier : String {
        return NSStringFromClass(self)
    }
}

class UITableViewCellValue1 : UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.value1, reuseIdentifier: reuseIdentifier)
    }
}

class UITableViewCellValue2 : UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.value2, reuseIdentifier: reuseIdentifier)
    }
}

class UITableViewCellSubtitle : UITableViewCell {
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
    }
}

extension UICollectionViewCell {
    
    static var defaultIdentifier : String {
        return NSStringFromClass(self)
    }
}

extension UITableViewHeaderFooterView {
    
    static var defaultIdentifier : String {
        return NSStringFromClass(self)
    }
}

extension UISearchBar {
    
    /// 文字的自动纠错功能(首字母大写、自动纠错、检查拼写、...)
    var autoSpell : Bool {
        
        set {
            if newValue {
                autocapitalizationType = .sentences
                autocorrectionType = .yes
                spellCheckingType = .yes
            } else {
                autocapitalizationType = .none
                autocorrectionType = .no
                spellCheckingType = .no
            }
        }
        
        get {
            return autocapitalizationType != .none || autocorrectionType != .no || spellCheckingType != .no
        }
    }
}

extension UITextField {
    
    /// 文字的自动纠错功能(首字母大写、自动纠错、检查拼写、...)
    var autoSpell : Bool {
        
        set {
            if newValue {
                autocapitalizationType = .sentences
                autocorrectionType = .yes
                spellCheckingType = .yes
            } else {
                autocapitalizationType = .none
                autocorrectionType = .no
                spellCheckingType = .no
            }
        }
        
        get {
            return autocapitalizationType != .none || autocorrectionType != .no || spellCheckingType != .no
        }
    }
}

extension UITextView {
    
    /// 文字的自动纠错功能(首字母大写、自动纠错、检查拼写、...)
    var autoSpell : Bool {
        
        set {
            if newValue {
                autocapitalizationType = .sentences
                autocorrectionType = .yes
                spellCheckingType = .yes
            } else {
                autocapitalizationType = .none
                autocorrectionType = .no
                spellCheckingType = .no
            }
        }
        
        get {
            return autocapitalizationType != .none || autocorrectionType != .no || spellCheckingType != .no
        }
    }
}

enum UINavigationBarStyle: Int {
    case dark = 0
    case light
    case translucent
}

extension UINavigationBar {
    
    var navigationBarStyle : UINavigationBarStyle {
        
        set {
            if newValue == .light {
                self.setBackgroundImage(UIImage(named: "Kosmos.bundle/navi_background_light"), for: .default)
            } else if newValue == .dark {
                if UIDevice.current.iPhoneX {
                    self.setBackgroundImage(UIImage(named: "Kosmos.bundle/navi_background_dark_ipx"), for: .default)
                } else {
                    self.setBackgroundImage(UIImage(named: "Kosmos.bundle/navi_background_dark"), for: .default)
                }
            } else {
                self.setBackgroundImage(UIImage(), for: .default)
            }
        }
        
        get {
            return .light
        }
    }
    
    /// 进入某个界面时, 要求将导航栏透明. 此方法简化这个操作
    var transparencyFactor : (UIImage?, UIImage?, Bool)? {
        
        get {
            let storedBackgroundImage = backgroundImage(for: .default)
            let storedShadowImage = shadowImage
            let storedTranslucent = isTranslucent
            return (storedBackgroundImage, storedShadowImage, storedTranslucent)
        }
        
        set {
            setBackgroundImage(newValue?.0, for: .default)
            shadowImage = newValue?.1
            isTranslucent = newValue?.2 ?? false
        }
    }
    
    /// 设置导航栏透明
    func setTransparency() {
        let image = UIImage()
        setBackgroundImage(image, for: .default)
        shadowImage = image
        isTranslucent = true
    }
}

extension UINavigationController {
    
    func popToLastViewController(animated: Bool) {
        _ = self.popViewController(animated: animated)
    }
}

extension UIBarButtonItem {
    
    /// 尝试将customView作为UIButton输出
    var customViewAsButton: UIButton? {
        return customView as? UIButton
    }
}

extension UIViewController {
    
    @objc func naviback() {
        _ = self.navigationController?.popViewController(animated: true)
    }
}

extension UIAlertController {
    
    /// 添加UIAlertAction的便捷方法
    func addDefault(withTitle title: String?, handler: ((UIAlertAction) -> Void)? = nil) {
        self.addAction(UIAlertAction(title: title, style: .default, handler: handler))
    }
    
    /// 添加UIAlertAction的便捷方法
    func addCancel(withTitle title: String?, handler: ((UIAlertAction) -> Void)? = nil) {
        self.addAction(UIAlertAction(title: title, style: .cancel, handler: handler))
    }
    
    /// 添加UIAlertAction的便捷方法
    func addDestructive(withTitle title: String?, handler: ((UIAlertAction) -> Void)? = nil) {
        self.addAction(UIAlertAction(title: title, style: .destructive, handler: handler))
    }
    
    /// 弹出提示框
    static func showAlert(withMessage message: String?) {
        return UIAlertController.showAlert(withTitle: nil, message: message, completion: nil)
    }
    
    /// 弹出提示框
    static func showAlert(withMessage message: String?, completion: (() -> Void)?) {
        return UIAlertController.showAlert(withTitle: nil, message: message, completion: completion)
    }
    
    /// 弹出提示框
    static func showAlert(withTitle title: String?, message: String?) {
        return UIAlertController.showAlert(withTitle: title, message: message, completion: nil)
    }
    
    /// 弹出提示框, 并设置点击确定后的事件
    static func showAlert(withTitle title: String?, message: String?, completion: (() -> Void)?) {
        if let presented = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController {
            NSLog("want to present an UIAlertController when it is exsited, so dismiss the old one")
            presented.dismiss(animated: false, completion: nil)
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addCancel(withTitle: "确定") { action in
            completion?()
        }
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    /// 弹出询问框, 并设置点击确定后的事件
    static func showQuestion(withMessage message: String?, completion: (() -> Void)?) {
        return UIAlertController.showQuestion(withTitle: nil, message: message, completion: completion)
    }
    
    /// 弹出询问框, 并设置点击确定后的事件
    static func showQuestion(withTitle title: String?, message: String?, completion: (() -> Void)?) {
        if let presented = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController {
            NSLog("want to present an UIAlertController when it is exsited, so dismiss the old one")
            presented.dismiss(animated: false, completion: nil)
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addDefault(withTitle: "确定") { action in
            completion?()
        }
        alert.addCancel(withTitle: "取消") { action in
            
        }
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

extension UIDevice {
    
    /// 这个设备是模拟器
    var isSimulator: Bool {
        #if arch(i386) || arch(x86_64)
            return true
        #else
            return false
        #endif
    }
    
    /// 这个设备是iPhoneX
    var iPhoneX: Bool {
        return UIScreen.main.bounds.height == 812
    }
}

/// 放光文字
class UIGlowLabel: UILabel {
    
    /// 发光区域的偏移
    var glowOffset : CGSize = .zero
    
    /// 发光区域的颜色
    var glowColor : UIColor = .black
    
    /// 发光区域的长度
    var glowSize : CGFloat = 2.0
    
    override func drawText(in rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        context.setShadow(offset: glowOffset, blur: glowSize, color: glowColor.cgColor)
        super.drawText(in: rect)
        context.restoreGState()
    }
}

/// 带角标的UIImageView
class UIImageViewWithBadge: UIImageView {

    private let textLabel = UILabel()
    
    var badgeValue : String {
        set { textLabel.text = newValue }
        get { return textLabel.text ?? "" }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.textAlignment = .right
        textLabel.font = .systemFont(ofSize: 8)
        textLabel.shadowColor = UIColor.white
        textLabel.shadowOffset = CGSizeMake(-1, 1)
        addSubview(textLabel)
        NSLayoutConstraint(item: textLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -2.0).isActive = true
        NSLayoutConstraint(item: textLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: -6.0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

/// 可收缩的视图
class UIShrinkableView: UIView {
    
    private let tapDetect = UIView()
    
    weak var delegate : UIShrinkableViewDelegate?
    
    /// 通过更改这个约束的active值, 来展示动画. 子类必须实现它
    var constraint : NSLayoutConstraint!
    
    /// 展开时, 将背景透明度设置为
    var tapDetectAlpha : CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 默认隐藏. 当show时, 先置为true将自己显示出来, 再执行动画; 当hide时, 类似操作
        isHidden = true
        
        tapDetect.frame = self.bounds
        tapDetect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tapDetect.backgroundColor = .black
        tapDetect.alpha = 0.0
        addSubview(tapDetect)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapView(_:)))
        tapDetect.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapView(_ recognizer: UITapGestureRecognizer) {
        hide()
    }
    
    func show() {
        
        self.isHidden = false
        self.delegate?.shrinkableView(self, willShown: true)
        
        UIView.animate(withDuration: 0.4, animations: {
            self.constraint.isActive = true
            self.tapDetect.alpha = self.tapDetectAlpha
            self.layoutIfNeeded()
        }, completion: { (finished: Bool) in
            self.delegate?.shrinkableView(self, didShown: true)
        })
    }
    
    func hide() {
        
        self.delegate?.shrinkableView(self, willHidden: true)
        
        UIView.animate(withDuration: 0.4, animations: {
            self.constraint.isActive = false
            self.tapDetect.alpha = 0.0
            self.layoutIfNeeded()
        }, completion: { (finished: Bool) in
            self.isHidden = true
            self.delegate?.shrinkableView(self, didHidden: true)
        })
    }
}

protocol UIShrinkableViewDelegate : NSObjectProtocol {
    
    func shrinkableView(_ sender: UIShrinkableView, willShown: Bool)
    
    func shrinkableView(_ sender: UIShrinkableView, didShown: Bool)
    
    func shrinkableView(_ sender: UIShrinkableView, willHidden: Bool)
    
    func shrinkableView(_ sender: UIShrinkableView, didHidden: Bool)
}
