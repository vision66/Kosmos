//
//  IIImagePickerController.swift
//  demo
//
//  Created by weizhen on 2017/8/11.
//  Copyright © 2017年 Wuhan Mengxin Technology Co., Ltd. All rights reserved.
//

import UIKit


let UIImagePickerControllerCropSize: String = "UIImagePickerControllerCropSize" // an NSValue (CGSize)


class IIImagePickerController: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    ///
    /// A dictionary containing the original image and the edited image, if an image was picked; or a filesystem URL for the movie, if a movie was picked.
    ///
    /// The dictionary also contains any relevant editing information.
    ///
    /// The keys for this dictionary are listed in Editing Information Keys.
    ///
    var mediaInfo = [String : Any]()
    
    /// the crop area size, default is (0.0, 0.0).
    var cropSize : CGSize {
        
        set {
            self.mediaInfo[UIImagePickerControllerCropSize] = newValue
        }
        
        get {
            return self.mediaInfo[UIImagePickerControllerCropSize] as? CGSize ?? CGSize.zero
        }
    }
    
    ///
    /// The delegate receives notifications when the user picks an image or movie, or exits the picker interface.
    ///
    /// The delegate also decides when to dismiss the picker interface, so you must provide a delegate to use a picker.
    ///
    /// If this property is nil, the picker is dismissed immediately if you try to show it.
    ///
    var delegate2 : IIImagePickerControllerDelegate? = nil
    
    override func loadView() {
        super.loadView()
        self.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        for item in info {
            self.mediaInfo[item.key] = item.value
        }
        
        if self.cropSize != CGSize.zero {
            let imageCroper = UIImageCroperController()
            picker.pushViewController(imageCroper, animated: true)
        } else if self.delegate2 == nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.delegate2?.imagePickerControllerEx(self, didFinishPickingMediaWithInfo: self.mediaInfo)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        if self.delegate2 == nil {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        self.delegate2?.imagePickerControllerExDidCancel(self)
    }
}


protocol IIImagePickerControllerDelegate : NSObjectProtocol {
    
    func imagePickerControllerEx(_ picker: IIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    
    func imagePickerControllerExDidCancel(_ picker: IIImagePickerController)
}


extension CGRect {
    
    /// size scaled to fit with fixed aspect. remainder is transparent
    func scaleAspectFit(by size: CGSize) -> CGRect {
        var size_w = size.width
        var size_h = size.height
        let size_rate = size.width / size.height
        if size_rate < self.size.width / self.size.height {
            size_w = self.size.height * size_rate
            size_h = self.size.height
        } else {
            size_w = self.size.width
            size_h = self.size.width / size_rate
        }
        return CGRect(x: self.origin.x + self.size.width / 2 - size_w / 2, y: self.origin.y + self.size.height / 2 - size_h / 2, width: size_w, height: size_h)
    }
    
    /// size scaled to fill with fixed aspect. some portion of content may be clipped.
    func scaleAspectFill(by size: CGSize) -> CGRect {
        var size_w = size.width
        var size_h = size.height
        let size_rate = size.width / size.height
        if size_rate > self.size.width / self.size.height {
            size_w = self.size.height * size_rate
            size_h = self.size.height
        } else {
            size_w = self.size.width
            size_h = self.size.width / size_rate
        }
        return CGRect(x: self.origin.x + self.size.width / 2 - size_w / 2, y: self.origin.y + self.size.height / 2 - size_h / 2, width: size_w, height: size_h)
    }
}


class UIImageCroperController: UIViewController {
    
    let imageView = UIImageView()
    
    let maskView = UIImageCroperMask()
    
//    let testView = UIImageView()
    
    let toolbar = UIToolbar()
    
    var imagePickerContoller : IIImagePickerController {
        return self.navigationController as! IIImagePickerController
    }
    
    var shownRect : CGRect {
        return self.view.bounds // 整个操作区域, 将来或许不会包含导航条、工具条
    }
    
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.white
        
        imageView.image = self.imagePickerContoller.mediaInfo[UIImagePickerControllerOriginalImage] as? UIImage
        view.addSubview(imageView)
        
        maskView.cropSize = self.imagePickerContoller.mediaInfo[UIImagePickerControllerCropSize] as! CGSize
        view.addSubview(maskView)
        
//        testView.backgroundColor = UIColor.brown
//        view.addSubview(testView)
        
        let barItem1 = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.plain, target: self, action: #selector(naviback))
        let barItem2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let barItem3 = UIBarButtonItem(title: "确定", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.navisave))
        
        toolbar.barStyle = .black
        toolbar.items = [barItem1, barItem2, barItem3]
        view.addSubview(toolbar)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.numberOfTapsRequired = 2
        tap.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        pan.minimumNumberOfTouches = 1
        self.view.addGestureRecognizer(pan)
        
        let pin = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch(_:)))
        self.view.addGestureRecognizer(pin)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.imageView.frame = self.shownRect.scaleAspectFit(by: maskView.cropSize).scaleAspectFill(by: self.imageView.image!.size)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.maskView.frame = self.shownRect
        self.toolbar.frame = CGRect(x: 0, y: self.view.bounds.size.height - 40, width: self.view.bounds.size.width, height: 40)
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        self.imageView.frame = self.shownRect.scaleAspectFit(by: maskView.cropSize).scaleAspectFill(by: self.imageView.image!.size)
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        
        let offset = recognizer.translation(in: imageView)
        
        let cropRect = self.shownRect.scaleAspectFit(by: maskView.cropSize)
        
        let crop_w  = cropRect.size.width
        let crop_h = cropRect.size.height
        let crop_cx = crop_w / 2 + cropRect.origin.x
        let crop_cy = crop_h / 2 + cropRect.origin.y
        let image_w  = imageView.bounds.size.width
        let image_h = imageView.bounds.size.height
        var image_cx = imageView.center.x + offset.x
        var image_cy = imageView.center.y + offset.y
        
        if image_w > crop_w {
            
            if image_cx - image_w / 2 > crop_cx - crop_w / 2 {
                image_cx = crop_cx - crop_w / 2 + image_w / 2
            }
            
            if image_cx + image_w / 2 < crop_cx + crop_w / 2 {
                image_cx = crop_cx + crop_w / 2 - image_w / 2
            }
        }
        else {
            image_cx = crop_cx
        }
        
        if image_h > crop_h {
            
            if image_cy - image_h / 2 > crop_cy - crop_h / 2 {
                image_cy = crop_cy - crop_h / 2 + image_h / 2
            }
            
            if image_cy + image_h / 2 < crop_cy + crop_h / 2 {
                image_cy = crop_cy + crop_h / 2 - image_h / 2
            }
        }
        else {
            image_cy = crop_cy
        }
        
        imageView.center = CGPoint(x: image_cx, y: image_cy)
        imageView.bounds = CGRect(x: 0, y: 0, width: image_w, height: image_h)
        
        recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
    }
    
    @objc func handlePinch(_ recognizer: UIPinchGestureRecognizer) {
        
        let cropRect = self.shownRect.scaleAspectFit(by: maskView.cropSize)
        
        let crop_w = cropRect.size.width
        let crop_h = cropRect.size.height
        let crop_cx = crop_w / 2 + cropRect.origin.x
        let crop_cy = crop_h / 2 + cropRect.origin.y
        var image_cx = imageView.center.x
        var image_cy = imageView.center.y
        let image_w = imageView.bounds.size.width + (recognizer.scale - 1.0) * 1000
        let image_h = image_w * imageView.bounds.size.height / imageView.bounds.size.width
        
        if image_w < crop_w || image_h < crop_h {
            recognizer.scale = 1.0
            return
        }
        
        if image_w > crop_w {
            
            if image_cx - image_w / 2 > crop_cx - crop_w / 2 {
                image_cx = crop_cx - crop_w / 2 + image_w / 2
            }
            
            if image_cx + image_w / 2 < crop_cx + crop_w / 2 {
                image_cx = crop_cx + crop_w / 2 - image_w / 2
            }
        }
        else {
            image_cx = crop_cx
        }
        
        if image_h > crop_h {
            
            if image_cy - image_h / 2 > crop_cy - crop_h / 2 {
                image_cy = crop_cy - crop_h / 2 + image_h / 2
            }
            
            if image_cy + image_h / 2 < crop_cy + crop_h / 2 {
                image_cy = crop_cy + crop_h / 2 - image_h / 2
            }
        }
        else {
            image_cy = crop_cy
        }
        
        imageView.center = CGPoint(x: image_cx, y: image_cy)
        imageView.bounds = CGRect(x: 0, y: 0, width: image_w, height: image_h)
        
        recognizer.scale = 1.0
    }
    
    override func naviback() {
        self.navigationController?.popViewController(animated: true)
        self.imagePickerContoller.startVideoCapture()
    }
    
    @objc func navisave() {
        
        let imagePickerContoller = self.imagePickerContoller
        
        if imagePickerContoller.delegate2 == nil {
            imagePickerContoller.dismiss(animated: true, completion: nil)
            return
        }
        
        let image = imageView.image!
        let viewRect = self.imageView.frame
        let cropRect = self.shownRect.scaleAspectFit(by: maskView.cropSize)
        let moveRect = cropRect.applying(CGAffineTransform(translationX: -viewRect.origin.x, y: -viewRect.origin.y))
        let rate = image.size.width / viewRect.size.width
        let lastRect = moveRect.applying(CGAffineTransform(scaleX: rate, y: rate))
        
        guard let cgCropped = image.cgImage?.cropping(to: lastRect) else {
            imagePickerContoller.dismiss(animated: true, completion: nil)
            return
        }
        let cropped = UIImage(cgImage: cgCropped)
        
//self.testView.frame = CGRect(x: 0, y: 0, width: cropRect.size.width, height: cropRect.size.height)
//self.testView.image = cropped
        
        imagePickerContoller.mediaInfo[UIImagePickerControllerCropRect] = lastRect
        imagePickerContoller.mediaInfo[UIImagePickerControllerEditedImage] = cropped
        imagePickerContoller.delegate2?.imagePickerControllerEx(imagePickerContoller, didFinishPickingMediaWithInfo: imagePickerContoller.mediaInfo)
    }
}


class UIImageCroperMask: UIView {
    
    var cropSize : CGSize {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        self.cropSize = CGSize(width: 1.0, height: 1.0)
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        self.isUserInteractionEnabled = false        
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let cropRect = rect.scaleAspectFit(by: cropSize)
        
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(1)
        context.stroke(cropRect)
        
        context.setBlendMode(CGBlendMode.clear)
        context.fill(cropRect)
    }
}
