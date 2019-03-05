//
//  KosmosJavaScriptCore.swift
//  KosmosJavaScriptCore
//
//  Created by weizhen on 2018/7/11.
//  Copyright © 2018年 Wuhan Mengxin Technology Co., Ltd. All rights reserved.
//

import JavaScriptCore

extension JSContext {
    
    func install() {
        
        /* Console */
        let console = Console()
        setObject(console, forKeyedSubscript: "console" as NSCopying & NSObjectProtocol)
        
        /* XMLHttpRequest */
        setObject(XMLHttpRequest.self, forKeyedSubscript: "XMLHttpRequest" as NSCopying & NSObjectProtocol)
        
        /* Functions */
        let eval : @convention(block) (String)->JSValue? = { str in
            return JSContext.current().evaluateScript(str)
        }
        setObject(eval, forKeyedSubscript: "eval" as NSCopying & NSObjectProtocol)
    }
    
    @discardableResult
    func invokeMethod(_ method: String!, withArguments arguments: [Any]!, inObject object: String!) -> JSValue! {
        
        if let object = object {
            return objectForKeyedSubscript(object)?.invokeMethod(method, withArguments: arguments)
        } else {
            return objectForKeyedSubscript(method)?.call(withArguments: arguments)
        }
    }
}

extension JSValue {
    
    open override var description: String {
        if self.isNull { return "(Null)null" }
        if self.isNumber { return "(Number)\(toNumber()?.description ?? "null")" }
        if self.isString { return "(String)\(toString() ?? "null")" }
        if self.isDate { return "(Date)\(toDate()?.description ?? "null")" }
        if self.isUndefined { return "(Undefined)Undefined" }
        if self.isBoolean { return "(Boolean)\(toBool())" }
        if self.isArray { return "(Array)\(toArray()?.description ?? "null")" }
        if self.isObject { return "(Object)\(toObject().debugDescription )" }
        return "(Unknown)\(self)"
    }
    
    var asJSON : JSON {
        
        if self.isUndefined || self.isNull {
            return JSON.null
        }
        
        if self.isBoolean {
            return JSON(booleanLiteral: toBool())
        }
        
        if self.isDate {
            return JSON(stringLiteral: toDate().stringUsingDefault)
        }
        
        if self.isString {
            return JSON(stringLiteral: toString())
        }
        
        if self.isNumber {
            return JSON(floatLiteral: toDouble())
        }
        
        if self.isArray {
            
            let length = self.forProperty("length")!.toInt32().asInt

            var result = JSON([])
            
            for index in 0 ..< length {
                let item = self.objectAtIndexedSubscript(index)!.asJSON
                result.arrayObject?.append(item)
            }
            
            return result
        }
        
        if self.isObject {
            
            let names = context.invokeMethod("getOwnPropertyNames", withArguments: [self], inObject: "Object")!
            let count = names.forProperty("length")!.toInt32().asInt
            
            var result = JSON()
            
            for index in 0 ..< count {
                
                let name = names.objectAtIndexedSubscript(index)!.toString()!
                
                result[name] = self.forProperty(name)!.asJSON
            }
            
            return result
        }
        
        return JSON.null
    }
}

@objc protocol ConsoleInJS : JSExport {
    
    func log(_ format: String)
}

@objc class Console : NSObject, ConsoleInJS {
    
    func log(_ format: String) {
        print(format)
    }
}

@objc protocol XMLHttpRequestInJS : JSExport {
    
    var onreadystatechange : JSValue? { get set }
    
    var readyState : Int { get }
    
    var status : Int { get }
    
    var statusText : String { get }
    
    var responseText : String { get }
    
    init()
    
    func open(_ method: String, _ url: String, _ async: Bool)
    
    func send()
    
    func overrideMimeType(_ mime: String)
}

@objc class XMLHttpRequest : NSObject, URLSessionDataDelegate, XMLHttpRequestInJS {
    
    var onreadystatechange : JSValue?
    
    /**
     - 0 UNSENT           (未打开) open()方法还未被调用.
     - 1 OPENED           (未发送) open()方法已经被调用.
     - 2 HEADERS_RECEIVED (已获取响应头) send()方法已经被调用, 响应头和响应状态已经返回.
     - 3 LOADING          (正在下载响应体) 响应体下载中; responseText中已经获取了部分数据.
     - 4 DONE             (请求完成) 整个请求过程已经完毕.
     */
    var readyState : Int = 0 {
        didSet {
            _ = onreadystatechange?.call(withArguments: [])
        }
    }
    
    /// 该请求的响应状态码 (例如, 状态码200 表示一个成功的请求).只读.
    var status : Int = 0
    
    /// 该请求的响应状态信息,包含一个状态码和原因短语 (例如 "200 OK"). 只读.
    var statusText : String = ""
    
    var responseText : String = ""
    
    var request : NSMutableURLRequest!
    
    var session : URLSession!
    
    var task: URLSessionDataTask!
    
    var allData: Data!
    
    var semaphore : DispatchSemaphore?
    
    override required init() {
        super.init()
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }
    
    func open(_ method: String, _ url: String, _ async: Bool) {
        
        guard let url = URL(string: url) else {
            return
        }
        
        request = NSMutableURLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 10
        
        task = session.dataTask(with: request! as URLRequest)
        
        if async == false {
            semaphore = DispatchSemaphore(value: 0)
        }
        
        readyState = 1
    }
    
    func send() {
        task.resume()
        semaphore?.wait()
    }
    
    func overrideMimeType(_ mime: String) {

    }
    
    // URLSessionDelegate
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        //print("didBecomeInvalidWithError error: \(error?.localizedDescription ?? "null")")
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        //print("didReceive challenge: \(challenge)")
        
        // 这里检查质询的验证方式是否是服务器端证书验证
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            
            // 这里直接把证书包装对象拿到，
            let trustRef = challenge.protectionSpace.serverTrust!
            
            // 使用证书SecTrust对象来构造URLCredential，系统默认实现这里应该是要对SecTrust进行验证，而此处我们的目的就是要信任所有证书。因此跳过验证这一步。
            let trustCredential = URLCredential(trust: trustRef)

            // 通过回调函数告诉系统对于该质询的UrlCredential
            completionHandler(.useCredential, trustCredential)
            
        } else {
            
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        //print("forBackgroundURLSession session: \(session)")
    }
    
    // URLSessionTaskDelegate
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Swift.Void) {
        //print("willBeginDelayedRequest request: \(request)")
    }
    
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        //print("taskIsWaitingForConnectivity task: \(task)")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Swift.Void) {
        //print("willPerformHTTPRedirection response: \(response), newRequest request: \(request)")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        //print("didReceive challenge: \(challenge)")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Swift.Void) {
        //print("needNewBodyStream completionHandler: \(completionHandler)")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        //print("didSendBodyData bytesSent: \(bytesSent), totalBytesSent: \(totalBytesSent), totalBytesExpectedToSend: \(totalBytesExpectedToSend)")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        //print("didFinishCollecting metrics: \(metrics)")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        //print("didCompleteWithError error: \(error?.localizedDescription ?? "null")")
        
        if let error = error as NSError? {
            status = error.code
            statusText = error.localizedDescription
        }
        
        if let data = allData {
            let encodings = [String.Encoding.utf8, .GB18030]
            var string : String?
            for encoding in encodings {
                string = String(data: data, encoding: encoding)
                if string != nil { break }
            }
            responseText = string ?? ""
        }
        
        readyState = 4
        
        semaphore?.signal()
    }
    
    // - URLSessionDataDelegate
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Swift.Void) {
        //print("didReceive response: \(response)")
        
        let httpURLResponse = response as! HTTPURLResponse
        status = httpURLResponse.statusCode
        readyState = 2
        
        if httpURLResponse.statusCode != 200 {
            completionHandler(.cancel)
        } else {
            allData = Data()
            completionHandler(.allow)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        //print("didBecome downloadTask: \(downloadTask)")
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        //print("didBecome streamTask: \(streamTask)")
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        //print("didReceive data: \(data)")
        allData.append(data)
        readyState = 3
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Swift.Void) {
        //print("willCacheResponse proposedResponse: \(proposedResponse)")
        completionHandler(proposedResponse)
    }
}
