//
//  UIVerificationController.swift
//  character
//
//  Created by weizhen on 2018/3/22.
//  Copyright © 2018年 weizhen. All rights reserved.
//

import UIKit

enum UIVerificationType : Int {
    case verify // 用于验证密码
    case delete // 用于删除密码
    case create // 用于创建密码
    case modify // 用于修改密码
}

/// 用于创建(修改、删除、验证)密码的视图, 类似于iPhone解锁界面. 请使用present来显示这个视图
class UIVerificationController: UIViewController, UIVerificationDelegate {
    
    var completion : (() -> Swift.Void)?
    
    /// 将会从UserDefaults的这个key下读取当前密码; 如果是create/modify, 则会将新密码存入到这个key下
    private let kPassword = "login password"
    
    /// 用户操作的视图. 当前设备是iPad时, 将会居中显示; 当前设备是iPhone时, 会占满全屏
    private let verification : UIVerification
    
    /// 构造器, type 用于创建、修改、删除, 或是验证
    init(type: UIVerificationType) {
        self.verification = UIVerification(type: type)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = UIColor(white: 0.4, alpha: 1.0)
        
        verification.translatesAutoresizingMaskIntoConstraints = false
        verification.delegate = self
        view.addSubview(verification)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            NSLayoutConstraint(item: verification, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: verification, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: verification, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320).isActive = true
            NSLayoutConstraint(item: verification, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 480).isActive = true
        } else {
            NSLayoutConstraint(item: verification, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: verification, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: verification, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: verification, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        }
        
        verification.theOldPassword = UserDefaults.standard.string(forKey: kPassword) ?? ""
    }
    
    private var storedStatusBarStyle = UIStatusBarStyle.default
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        storedStatusBarStyle = UIApplication.shared.statusBarStyle
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = storedStatusBarStyle
    }
    
    func verification(_ sender: UIVerification, cancelWith unused: Int) {
        dismiss(animated: true, completion: nil)
    }
    
    func verification(_ sender: UIVerification, completeAt type: UIVerificationType) {
        
        if type == .create || type == .modify {
            UserDefaults.standard.set(verification.theNewPassword, forKey: kPassword)
        }
        
        if type == .delete {
            UserDefaults.standard.set("", forKey: kPassword)
        }
        
        dismiss(animated: true, completion: nil)
    }
}

/// 用于创建(修改、删除、验证)密码的视图, 类似于iPhone解锁界面.
class UIVerification: UIView, UIVerificationKeycontrolDelegate {
    
    /// 输出验证结果
    weak var delegate : UIVerificationDelegate?
    
    /// 正在使用的密码
    var theOldPassword : String = ""
    
    /// 重置密码/创建密码: 保存上一次的输入结果
    var theNewPassword : String = ""
    
    /// 模拟导航栏
    let navigation = UIVerificationNavigation()
    
    /// 显示输入状态, 以及验证结果
    var infomation = UIVerificationInfomation()
    
    /// infomation的备份, 用于动画
    var background = UIVerificationInfomation()
    
    /// 模拟输入键盘
    let keycontrol = UIVerificationKeycontrol()
    
    /// 用于创建、修改、删除, 或是验证
    var type : UIVerificationType
    
    /// 重置密码: 验证当前密码成功
    var theOldPasswordOK = false
    
    init(type: UIVerificationType) {
        self.type = type
        super.init(frame: .zero)
        
        backgroundColor = .gray
        layer.masksToBounds = true
        
        navigation.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        addSubview(navigation)
        
        addSubview(infomation)
        
        addSubview(background)
        
        keycontrol.delegate = self
        addSubview(keycontrol)
        
        if type == .verify {
            navigation.title = "验证密码"
            navigation.hideCancelButton = true
            infomation.field = ""
            infomation.title = "请输入当前密码"
        } else if type == .delete {
            navigation.title = "删除密码"
            navigation.hideCancelButton = false
            infomation.field = ""
            infomation.title = "请输入当前密码"
        } else if type == .create {
            navigation.title = "创建密码"
            navigation.hideCancelButton = false
            infomation.field = ""
            infomation.title = "请输入新密码"
        } else { // type == .modify
            navigation.title = "修改密码"
            navigation.hideCancelButton = false
            infomation.field = ""
            infomation.title = "请输入当前密码"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let sfw = bounds.size.width
        let sfh = bounds.size.height
        
        navigation.frame = CGRectMake(0, 0, sfw, 64)
        infomation.frame = CGRectMake(0, 64, sfw, sfh-64-216)
        background.frame = CGRectMake(sfw, 64, sfw, sfh-64-216)
        keycontrol.frame = CGRectMake(0, sfh-216, sfw, 216)
    }
    
    @objc func cancelButtonClicked() {
        delegate?.verification(self, cancelWith: 0)
    }
    
    @objc func calcNextOperation() {
        if type == .verify || type == .delete {
            calcForVerify()
        } else if type == .create {
            calcForCreate()
        } else { // type == .modify
            calcForModify()
        }
    }
    
    func calcForVerify() {
        
        if infomation.field == theOldPassword {
            infomation.error = "密码正确!"
            delegate?.verification(self, completeAt: type)
            return
        }
        
        infomation.error = "密码错误, 请重试!"
        infomation.field = ""
        
        let center = infomation.center
        
        // 显示左右震动的效果
        UIView.animateKeyframes(withDuration: 0.2, delay: 0.0, options: [.calculationModeLinear], animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0.00, relativeDuration: 0.25, animations: {
                self.infomation.center = CGPointMake(center.x + 10, center.y)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.50, animations: {
                self.infomation.center = CGPointMake(center.x - 10, center.y)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25, animations: {
                self.infomation.center = CGPointMake(center.x, center.y)
            })
            
        }, completion: nil)
    }
    
    func calcForCreate() {
        
        // 已收集到全部输入的密码字符, 确保当前是创建密码的界面(theNewPassword.length == 0), 将输入的密码保存起来, 将此界面送走, 引入一个新的密码界面, 用于验证密码
        if theNewPassword.length == 0 {
            
            theNewPassword = infomation.field
            
            let frame = infomation.frame
            background.frame = CGRectMake(frame.origin.x + frame.size.width, frame.origin.y, frame.size.width, frame.size.height)
            background.title = "请再次输入密码"
            background.error = ""
            background.field = ""
            
            // 显示向左移动的效果
            UIView.animate(withDuration: 0.5, animations: {
                self.infomation.frame = CGRectMake(frame.origin.x - frame.size.width, frame.origin.y, frame.size.width, frame.size.height)
                self.background.frame = CGRectMake(frame.origin.x,                    frame.origin.y, frame.size.width, frame.size.height)
            }, completion: { finished in
                let temp = self.infomation
                self.infomation = self.background
                self.background = temp
            })
            
            return
        }
        
        // 已收集到全部输入的密码字符, 确保当前是验证密码的界面. 验证结果是两次输入的密码相同, 表示创建密码成功, 结束所有
        if infomation.field == theNewPassword {
            infomation.error = "密码正确!"
            delegate?.verification(self, completeAt: type)
            return
        }
        
        // 已收集到全部输入的密码字符, 确保当前是验证密码的界面. 验证结果是两次输入的密码不同, 表示创建密码失败, 退回到上个界面(创建密码的界面)
        
        theNewPassword = ""
        
        let frame = infomation.frame
        background.frame = CGRectMake(frame.origin.x - frame.size.width, frame.origin.y, frame.size.width, frame.size.height)
        background.title = "请输入新密码"
        background.error = "两次输入的密码不同, 请重试!"
        background.field = ""
        
        // 显示向右移动的效果
        UIView.animate(withDuration: 0.5, animations: {
            self.infomation.frame = CGRectMake(frame.origin.x + frame.size.width, frame.origin.y, frame.size.width, frame.size.height)
            self.background.frame = CGRectMake(frame.origin.x,                    frame.origin.y, frame.size.width, frame.size.height)
        }, completion: { finished in
            let temp = self.infomation
            self.infomation = self.background
            self.background = temp
        })
    }
    
    func calcForModify() {
        
        if theOldPasswordOK == false {
            
            if infomation.field == theOldPassword {
                
                theOldPasswordOK = true
                
                let frame = infomation.frame
                background.frame = CGRectMake(frame.origin.x + frame.size.width, frame.origin.y, frame.size.width, frame.size.height)
                background.title = "请输入新密码"
                background.error = "验证通过!"
                background.field = ""
                
                // 显示向左移动的效果
                UIView.animate(withDuration: 0.5, animations: {
                    self.infomation.frame = CGRectMake(frame.origin.x - frame.size.width, frame.origin.y, frame.size.width, frame.size.height)
                    self.background.frame = CGRectMake(frame.origin.x,                    frame.origin.y, frame.size.width, frame.size.height)
                }, completion: { finished in
                    let temp = self.infomation
                    self.infomation = self.background
                    self.background = temp
                })
            }
            else {
                
                infomation.error = "密码错误, 请重试!"
                infomation.field = ""
                
                let center = infomation.center
                
                // 显示左右震动的效果
                UIView.animateKeyframes(withDuration: 0.2, delay: 0.0, options: [.calculationModeLinear], animations: {
                    
                    UIView.addKeyframe(withRelativeStartTime: 0.00, relativeDuration: 0.25, animations: {
                        self.infomation.center = CGPointMake(center.x + 10, center.y)
                    })
                    
                    UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.50, animations: {
                        self.infomation.center = CGPointMake(center.x - 10, center.y)
                    })
                    
                    UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25, animations: {
                        self.infomation.center = CGPointMake(center.x, center.y)
                    })
                    
                }, completion: nil)
            }
        }
        else if theNewPassword.length == 0 {
            
            theNewPassword = infomation.field
            
            let frame = infomation.frame
            background.frame = CGRectMake(frame.origin.x + frame.size.width, frame.origin.y, frame.size.width, frame.size.height)
            background.title = "请确认密码"
            background.error = ""
            background.field = ""
            
            // 显示向左移动的效果
            UIView.animate(withDuration: 0.5, animations: {
                self.infomation.frame = CGRectMake(frame.origin.x - frame.size.width, frame.origin.y, frame.size.width, frame.size.height)
                self.background.frame = CGRectMake(frame.origin.x,                    frame.origin.y, frame.size.width, frame.size.height)
            }, completion: { finished in
                let temp = self.infomation
                self.infomation = self.background
                self.background = temp
            })
        }
        else {
            
            if infomation.field == theNewPassword {
                infomation.error = "修改密码成功!"
                delegate?.verification(self, completeAt: type)
            }
            else {
                
                theNewPassword = ""
                
                let frame = infomation.frame
                background.frame = CGRectMake(frame.origin.x - frame.size.width, frame.origin.y, frame.size.width, frame.size.height)
                background.title = "请输入新密码"
                background.error = "与上次的密码不同!"
                background.field = ""
                
                // 显示向右移动的效果
                UIView.animate(withDuration: 0.5, animations: {
                    self.infomation.frame = CGRectMake(frame.origin.x + frame.size.width, frame.origin.y, frame.size.width, frame.size.height)
                    self.background.frame = CGRectMake(frame.origin.x,                    frame.origin.y, frame.size.width, frame.size.height)
                }, completion: { finished in
                    let temp = self.infomation
                    self.infomation = self.background
                    self.background = temp
                })
            }
        }
    }
    
    func verificationKeycontrol(_ sender: UIVerificationKeycontrol, buttonValue: String) {
        
        if buttonValue == "/" {
            return
        }
        
        if buttonValue == "<" {
            if infomation.field.length > 0 {
                let end = infomation.field.count - 1
                let sub = infomation.field.substring(from: 0, with: end)
                infomation.field = sub
            }
            return
        }
        
        if infomation.field.length < 6 {
            infomation.error = "" // 正在编辑时, 清理掉之前的错误提示
            infomation.field += buttonValue
            
            if infomation.field.length == 6 {
                perform(#selector(calcNextOperation), with: nil, afterDelay: 0.2)
            }
        }
    }
}

protocol UIVerificationDelegate : NSObjectProtocol {
    
    func verification(_ sender: UIVerification, cancelWith unused: Int)
    
    // 创建完成, 修改完成, 验证成功
    func verification(_ sender: UIVerification, completeAt type: UIVerificationType)
    
}

/// 模仿UINavigation的控件
class UIVerificationNavigation : UIView {
    
    let backgroundImage = UIImageView()
    
    let cancelButton = UIButton()
    
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .green
        
        backgroundImage.image = UIImage(named: "verification_nav")?.resizableImage(withCapInsets: UIEdgeInsetsMake(10, 10, 10, 10))
        addSubview(backgroundImage)
        
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(UIColor(hexInteger: 0x007aff), for: .normal)
        addSubview(cancelButton)
        
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black
        addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let sw = bounds.size.width
        let sh = bounds.size.height
        
        backgroundImage.frame = CGRectMake(0, 0, sw, sh)
        cancelButton.frame = CGRectMake(0, 20, 54, sh-20)
        titleLabel.frame = CGRectMake(0, 20, sw, sh-20)
    }
    
    var title : String? {
        set { titleLabel.text = newValue }
        get { return titleLabel.text }
    }
    
    var hideCancelButton : Bool {
        set { cancelButton.isHidden = newValue }
        get { return cancelButton.isHidden }
    }
    
    func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        cancelButton.addTarget(target, action: action, for: controlEvents)
    }
}

/// 模仿弹出的数字键盘
class UIVerificationKeycontrol: UIView {
    
    weak var delegate : UIVerificationKeycontrolDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(hexInteger: 0x8c8c8c)
        
        var names = (0...9).map { String(format: "verification_%d", $0) }
        names.append("verification_nil") // 空白键
        names.append("verification_del") // 删除键
        
        let size = CGSizeMake(40, 40)
        let background1 = UIImage.imageWithColor(UIColor(hexInteger: 0xffffff), size: size)
        let background2 = UIImage.imageWithColor(UIColor(hexInteger: 0xc5c5c5), size: size)
        
        for name in names {
            let image = UIImage(named: name)
            let button = UIButton()
            button.setImage(image, for: .normal)
            button.setBackgroundImage(background1, for: .normal)
            button.setBackgroundImage(background2, for: .highlighted)
            button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
            addSubview(button)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let sw = bounds.size.width
        let sh = bounds.size.height
        let sp : CGFloat = 1.0             // 分割线
        let bw1 = floor((sw - sp * 2) / 3) // row1和row3的按钮宽度
        let bw2 = sw - sp * 2 - bw1 * 2    // row2的按钮宽度
        let bh1 = floor((sh - sp * 3) / 4) // col1、col2、col3的按钮高度
        let bh2 = sh - sp * 3 - bh1 * 3    // col4的按钮高度
        
        subviews[ 1].frame = CGRectMake(0,      (bh1+sp)*0, bw1, bh1)
        subviews[ 2].frame = CGRectMake(bw1+sp, (bh1+sp)*0, bw2, bh1)
        subviews[ 3].frame = CGRectMake(sw-bw1, (bh1+sp)*0, bw1, bh1)
        
        subviews[ 4].frame = CGRectMake(0,      (bh1+sp)*1, bw1, bh1)
        subviews[ 5].frame = CGRectMake(bw1+sp, (bh1+sp)*1, bw2, bh1)
        subviews[ 6].frame = CGRectMake(sw-bw1, (bh1+sp)*1, bw1, bh1)
        
        subviews[ 7].frame = CGRectMake(0,      (bh1+sp)*2, bw1, bh1)
        subviews[ 8].frame = CGRectMake(bw1+sp, (bh1+sp)*2, bw2, bh1)
        subviews[ 9].frame = CGRectMake(sw-bw1, (bh1+sp)*2, bw1, bh1)
        
        subviews[10].frame = CGRectMake(0,      (bh1+sp)*3, bw1, bh2)
        subviews[ 0].frame = CGRectMake(bw1+sp, (bh1+sp)*3, bw2, bh2)
        subviews[11].frame = CGRectMake(sw-bw1, (bh1+sp)*3, bw1, bh2)
    }
    
    @objc func buttonPressed(_ button: UIButton) {
        let titles = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "/", "<"]
        let index = subviews.index(of: button)!
        let title = titles[index]
        delegate?.verificationKeycontrol(self, buttonValue: title)
    }
}

protocol UIVerificationKeycontrolDelegate : NSObjectProtocol {
    
    func verificationKeycontrol(_ sender: UIVerificationKeycontrol, buttonValue: String)
}

class UIVerificationInfomation: UIView {
    
    let titleLabel = UILabel()
    
    let errorLabel = UILabel()
    
    var imageViewArray = [UIImageView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(hexInteger: 0xefeff4)
        
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 16)
        addSubview(titleLabel)
        
        errorLabel.textAlignment = .center
        errorLabel.font = .systemFont(ofSize: 14)
        addSubview(errorLabel)
        
        let image1 = UIImage(named: "verification_empty")
        let image2 = UIImage(named: "verification_fill")
        
        for _ in 0 ... 5 {
            let imageView = UIImageView(image: image1, highlightedImage: image2)
            addSubview(imageView)
            imageViewArray.append(imageView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let sfw = bounds.size.width
        let sfh = bounds.size.height
        let scy = sfh / 2 // 中心点y
        let space : CGFloat = 28 // 圆点之间的间隔
        let minX = sfw / 2 - (6 - 1) * space / 2 // 最左边的点cx
        
        titleLabel.frame = CGRectMake(0, scy - 60, sfw, 30)
        errorLabel.frame = CGRectMake(0, scy + 30, sfw, 30)
        
        for (i, imageView) in imageViewArray.enumerated() {
            imageView.center = CGPointMake(minX + i * space, scy)
            imageView.bounds = CGRectMake(0, 0, 20, 20)
        }
    }
    
    var field : String = "" {
        didSet {
            for (i, imageView) in imageViewArray.enumerated() {
                imageView.isHighlighted = (i < field.count)
            }
        }
    }
    
    var title : String? {
        set { titleLabel.text = newValue }
        get { return titleLabel.text }
    }
    
    var error : String? {
        set { errorLabel.text = newValue }
        get { return errorLabel.text }
    }
}
