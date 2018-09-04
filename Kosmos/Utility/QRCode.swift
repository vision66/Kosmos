//
//  QRCode.swift
//  QRCode
//
//  Created by 刘凡 on 15/5/15.
//  Copyright (c) 2015年 joyios. All rights reserved.
//

import UIKit
import AVFoundation

class QRCode: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    /// corner line width
    private var lineWidth: CGFloat
    /// corner stroke color
    private var strokeColor: UIColor
    /// the max count for detection
    private var maxDetectedCount: Int
    /// current count for detection
    private var currentDetectedCount: Int = 0
    /// auto remove sub layers when detection completed
    private var autoRemoveSubLayers: Bool
    /// completion call back
    private var completedCallBack: ((_ stringValue: String) -> ())?
    /// the scan rect, default is the bounds of the scan view, can modify it if need
    var scanFrame: CGRect = CGRect.zero
    
    ///  init function
    ///
    ///  - returns: the scanner object
    override init() {
        self.lineWidth = 4
        self.strokeColor = UIColor.green
        self.maxDetectedCount = 20
        self.autoRemoveSubLayers = false
        super.init()
    }
    
    ///  init function
    ///
    ///  - parameter autoRemoveSubLayers: remove sub layers auto after detected code image
    ///  - parameter lineWidth:           line width, default is 4
    ///  - parameter strokeColor:         stroke color, default is Green
    ///  - parameter maxDetectedCount:    max detecte count, default is 20
    ///
    ///  - returns: the scanner object
    init(autoRemoveSubLayers: Bool, lineWidth: CGFloat = 4, strokeColor: UIColor = UIColor.green, maxDetectedCount: Int = 20) {
        self.lineWidth = lineWidth
        self.strokeColor = strokeColor
        self.maxDetectedCount = maxDetectedCount
        self.autoRemoveSubLayers = autoRemoveSubLayers
    }
    
    deinit {
        stopScan()
        removeAllLayers()
    }
    
    ///  prepare scan
    ///
    ///  - parameter view:       the scan view, the preview layer and the drawing layer will be insert into this view
    ///  - parameter completion: the completion call back
    func prepareScan(_ view: UIView, completion: @escaping (_ stringValue: String) -> Void) {
        
        scanFrame = view.bounds
        completedCallBack = completion
        currentDetectedCount = 0
        
        setupSession()
        setupLayers(view)
    }
    
    /// start scan
    func startScan() {
        
        clearDrawLayer()
        
        if session.isRunning == false {
            session.startRunning()
        }
    }
    
    /// stop scan
    func stopScan() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    private func setupLayers(_ view: UIView) {
        drawLayer.frame = view.bounds
        view.layer.insertSublayer(drawLayer, at: 0)
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
    }
    
    private func setupSession() {
        
        if session.isRunning {
            print("the capture session is running")
            return
        }
        
        guard let videoInput = videoInput else {
            print("can not find input device")
            return
        }
        
        if !session.canAddInput(videoInput) {
            print("can not add input device")
            return
        }
        
        if !session.canAddOutput(dataOutput) {
            print("can not add output device")
            return
        }
        
        session.addInput(videoInput)
        session.addOutput(dataOutput)
        
        dataOutput.metadataObjectTypes = dataOutput.availableMetadataObjectTypes
        dataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    }
    
    /// 注意, swift4和swift3中, 这个方法名不同
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        clearDrawLayer()
        
        for dataObject in metadataObjects {
            
            if let codeObject = dataObject as? AVMetadataMachineReadableCodeObject, let objectInLayer = previewLayer.transformedMetadataObject(for: codeObject) as? AVMetadataMachineReadableCodeObject {
                
                if scanFrame.contains(objectInLayer.bounds) {
                    
                    currentDetectedCount = currentDetectedCount + 1
                    
                    if currentDetectedCount > maxDetectedCount {
                        
                        session.stopRunning()
                        
                        // 目前的代码是探测到maxDetectedCount+1次, 才会进入这一部分. 我认为是有问题的, 应该是探测到maxDetectedCount个以内不同的值, 并全部记录下来, 才进入这里
                        if let string = codeObject.stringValue {
                            completedCallBack?(string)
                        }
                        
                        if autoRemoveSubLayers {
                            removeAllLayers()
                        }
                    }
                    
                    // transform codeObject
                    drawCodeCorners(objectInLayer)
                }
            }
        }
    }
    
    private func removeAllLayers() {
        previewLayer.removeFromSuperlayer()
        drawLayer.removeFromSuperlayer()
    }
    
    private func clearDrawLayer() {
        
        guard let sublayers = drawLayer.sublayers else {
            return
        }
        
        for layer in sublayers {
            layer.removeFromSuperlayer()
        }
    }
    
    private func drawCodeCorners(_ codeObject: AVMetadataMachineReadableCodeObject) {
        
        let points = codeObject.corners
        if points.count == 0 {
            return
        }
        
        let path = UIBezierPath()
        for point in points {
            if point == points.first {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = lineWidth
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.path = path.cgPath
        
        drawLayer.addSublayer(shapeLayer)
    }
    
    /// previewLayer
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    /// drawLayer
    private lazy var drawLayer = CALayer()
    
    /// session
    private lazy var session = AVCaptureSession()
    
    /// input
    private lazy var videoInput: AVCaptureDeviceInput? = {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return nil }
        return try? AVCaptureDeviceInput(device: device)
    }()
    
    /// output
    private lazy var dataOutput = AVCaptureMetadataOutput()
}

extension QRCode {
    
    ///  generate image
    ///
    ///  - parameter stringValue: string value to encoe
    ///  - parameter avatarImage: avatar image will display in the center of qrcode image
    ///  - parameter avatarScale: the scale for avatar image, default is 0.25
    ///
    ///  - returns: the generated image
    class func generateImage(_ stringValue: String, avatarImage: UIImage? = nil, avatarScale: CGFloat = 0.25) -> UIImage? {
        return generateImage(stringValue, avatarImage: avatarImage, avatarScale: avatarScale, color: CIColor(color: UIColor.black), backColor: CIColor(color: UIColor.white))
    }
    
    ///  Generate Qrcode Image
    ///
    ///  - parameter stringValue: string value to encoe
    ///  - parameter avatarImage: avatar image will display in the center of qrcode image
    ///  - parameter avatarScale: the scale for avatar image, default is 0.25
    ///  - parameter color:       the CI color for forenground, default is black
    ///  - parameter backColor:   th CI color for background, default is white
    ///
    ///  - returns: the generated image
    class func generateImage(_ stringValue: String, avatarImage: UIImage?, avatarScale: CGFloat = 0.25, color: CIColor, backColor: CIColor) -> UIImage? {
        
        // generate qrcode image
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")!
        qrFilter.setDefaults()
        qrFilter.setValue(stringValue.data(using: String.Encoding.utf8, allowLossyConversion: false), forKey: "inputMessage")
        
        let ciImage = qrFilter.outputImage
        
        // scale qrcode image
        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setDefaults()
        colorFilter.setValue(ciImage, forKey: "inputImage")
        colorFilter.setValue(color, forKey: "inputColor0")
        colorFilter.setValue(backColor, forKey: "inputColor1")
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let transformedImage = qrFilter.outputImage!.transformed(by: transform)
        
        let image = UIImage(ciImage: transformedImage)
        
        if avatarImage != nil {
            return insertAvatarImage(image, avatarImage: avatarImage!, scale: avatarScale)
        }
        
        return image
    }
    
    private class func insertAvatarImage(_ codeImage: UIImage, avatarImage: UIImage, scale: CGFloat) -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: codeImage.size.width, height: codeImage.size.height)
        UIGraphicsBeginImageContext(rect.size)
        
        codeImage.draw(in: rect)
        
        let avatarSize = CGSize(width: rect.size.width * scale, height: rect.size.height * scale)
        let x = (rect.width - avatarSize.width) * 0.5
        let y = (rect.height - avatarSize.height) * 0.5
        avatarImage.draw(in: CGRect(x: x, y: y, width: avatarSize.width, height: avatarSize.height))
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return result!
    }
}
