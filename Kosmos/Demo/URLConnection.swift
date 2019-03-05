//
//  URLConnection.swift
//  character
//
//  Created by weizhen on 2018/3/9.
//  Copyright © 2018年 weizhen. All rights reserved.
//

import UIKit

/// 错误定义
extension NSError {
    
    static let requestUrlError = NSError(domain: "com.kosmos.error", code: 1000, userInfo: [NSLocalizedDescriptionKey: "请求的URL格式不正确"])
    
    static let networkError = NSError(domain: "com.kosmos.error", code: 1000, userInfo: [NSLocalizedDescriptionKey: "网络错误"])
    
    static let networkBusy = NSError(domain: "com.kosmos.error", code: 1001, userInfo: [NSLocalizedDescriptionKey: "当前网络状态欠佳, 请重试"])
    
    static let responseDataIsNull = NSError(domain: "com.kosmos.error", code: 1002, userInfo: [NSLocalizedDescriptionKey: "没有获取到数据"])
    
    static let responseDataIsNotJson = NSError(domain: "com.kosmos.error", code: 1003, userInfo: [NSLocalizedDescriptionKey: "不是JSON格式的数据"])
}

/// URLConnection
typealias URLResponseHandler = (JSON?, Error?) -> Void

/// 与服务器间的HTTP通讯, 包括GET、POST, 以及POST上传文件
class URLConnection: NSObject {
    
    /// 单例
    static let `default`: URLConnection = {
        return URLConnection()
    }()
    
    /// URLSession
    private let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
    
    /// HTTP GET
    func GET(_ path: String, accept: String = "application/json", completionHandler: @escaping URLResponseHandler) {
        
        guard let url = URL(string: path) else {
            completionHandler(nil, NSError.requestUrlError)
            return
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        request.httpMethod = "GET"
        request.httpBody = nil
        request.setValue(accept, forHTTPHeaderField: "Accept")
        request.setValue(accept, forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error as NSError? {
                completionHandler(nil, error)
                KSLog("HTTP[GET] response: \(error.description)")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                KSLog("HTTP[GET] response: \(response.url!.absoluteString)")
            }
            
            if data == nil {
                completionHandler(nil, NSError.responseDataIsNull)
                KSLog("HTTP[GET] response: Data is null")
                return
            }
            
            guard let json = data?.asJSON else {
                completionHandler(nil, NSError.responseDataIsNotJson)
                KSLog("HTTP[GET] response: \(data?.stringUsingUTF8 ?? "not an utf8 string")")
                return
            }
            
            KSLog("HTTP[GET] response: \(json.description)")
            completionHandler(json, nil)
        }
        
        task.resume()
    }
    
    /// HTTP POST
    func POST(_ path: String, data: Data?, accept: String = "application/json", completionHandler: @escaping URLResponseHandler) {
        
        guard let url = URL(string: path) else {
            completionHandler(nil, NSError.requestUrlError)
            return
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue(accept, forHTTPHeaderField: "Accept")
        request.setValue(accept, forHTTPHeaderField: "Content-Type")
        
        KSLog("HTTP[POST] request head: \(request.description)")
        KSLog("HTTP[POST] request data: \(data?.stringUsingUTF8 ?? "null")")
        
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error as NSError? {
                completionHandler(nil, error)
                KSLog("HTTP[POST] response: \(error.description)")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                KSLog("HTTP[POST] response: \(response.url!.absoluteString)")
            }
            
            if data == nil {
                completionHandler(nil, NSError.responseDataIsNull)
                KSLog("HTTP[POST] response: Data is null")
                return
            }
            
            guard let json = data?.asJSON else {
                completionHandler(nil, NSError.responseDataIsNotJson)
                KSLog("HTTP[POST] response: \(data?.stringUsingUTF8 ?? "null")")
                return
            }
            
            KSLog("HTTP[POST] response: \(json.description)")
            completionHandler(json, nil)
        }
        
        task.resume()
    }
    
    /// HTTP POST FILE
    func upload(_ path: String, fileName: String, fileData: Data, completionHandler: @escaping URLResponseHandler) {
        
        guard let url = URL(string: path) else {
            completionHandler(nil, NSError.requestUrlError)
            return
        }
        
        let Boundary = "AaB03x"
        
        var sectionHead = "--\(Boundary)\r\n"
        sectionHead += "Content-Disposition: form-data; name=\"avatar\"; filename=\"\(fileName)\"\r\n"
        sectionHead += "Content-Type: image/jpeg\r\n\r\n"
        
        let sectionFoot = "\r\n--\(Boundary)--"
        
        var httpBody = Data()
        httpBody.append(sectionHead.dataUsingUTF8!)
        httpBody.append(fileData)
        httpBody.append(sectionFoot.dataUsingUTF8!)
        
        let content_type = "multipart/form-data; boundary=\(Boundary)"
        let content_length = httpBody.count.asString
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 30.0
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.setValue(content_type, forHTTPHeaderField: "Content-Type")
        request.setValue(content_length, forHTTPHeaderField: "Content-Length")
        
        KSLog("HTTP[UPLOAD] request head: \(request.description)")
        
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error as NSError? {
                completionHandler(nil, error)
                KSLog("HTTP[UPLOAD] response: \(error.description)")
                return
            }
            
            if let response = response as? HTTPURLResponse {
                KSLog("HTTP[UPLOAD] response: \(response.url!.absoluteString)")
            }
            
            if data == nil {
                completionHandler(nil, NSError.responseDataIsNull)
                KSLog("HTTP[UPLOAD] response: Data is null")
                return
            }
            
            guard let json = data?.asJSON else {
                completionHandler(nil, NSError.responseDataIsNotJson)
                KSLog("HTTP[POST] response: \(data?.stringUsingUTF8 ?? "null")")
                return
            }
            
            KSLog("HTTP[UPLOAD] response: \(json.description)")
            completionHandler(json, nil)
        }
        
        task.resume()
    }
}
