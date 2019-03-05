//
//  KosmosFoundation.swift
//  KosmosFoundation
//
//  Created by weizhen on 16/8/1.
//

import Foundation
import CoreLocation
import CoreGraphics

func +(left: CGFloat, right: Int) -> CGFloat { return left + CGFloat(right) }
func +(left: Int, right: CGFloat) -> CGFloat { return CGFloat(left) + right }
func -(left: CGFloat, right: Int) -> CGFloat { return left - CGFloat(right) }
func -(left: Int, right: CGFloat) -> CGFloat { return CGFloat(left) - right }
func *(left: CGFloat, right: Int) -> CGFloat { return left * CGFloat(right) }
func *(left: Int, right: CGFloat) -> CGFloat { return CGFloat(left) * right }
func /(left: CGFloat, right: Int) -> CGFloat { return left / CGFloat(right) }
func /(left: Int, right: CGFloat) -> CGFloat { return CGFloat(left) / right }

func +(left: Double, right: Int) -> Double { return left + Double(right) }
func +(left: Int, right: Double) -> Double { return Double(left) + right }
func -(left: Double, right: Int) -> Double { return left - Double(right) }
func -(left: Int, right: Double) -> Double { return Double(left) - right }
func *(left: Double, right: Int) -> Double { return left * Double(right) }
func *(left: Int, right: Double) -> Double { return Double(left) * right }
func /(left: Double, right: Int) -> Double { return left / Double(right) }
func /(left: Int, right: Double) -> Double { return Double(left) / right }

func +(left: Float, right: Int) -> Float { return left + Float(right) }
func +(left: Int, right: Float) -> Float { return Float(left) + right }
func -(left: Float, right: Int) -> Float { return left - Float(right) }
func -(left: Int, right: Float) -> Float { return Float(left) - right }
func *(left: Float, right: Int) -> Float { return left * Float(right) }
func *(left: Int, right: Float) -> Float { return Float(left) * right }
func /(left: Float, right: Int) -> Float { return left / Float(right) }
func /(left: Int, right: Float) -> Float { return Float(left) / right }

/// 仿制的NSLog. 因为在swift中stderr等影响不了NSLog
func KSLog(line: Int = #line, file: String = #file, function: String = #function, _ format: String, _ args: CVarArg...) {
    
    let formatDate = Date().string(using: "yyyy-MM-dd HH:mm:ss.SSSSSSZ")
    
    let executable = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
    
    //let codeMethod = { () -> String in
    //    let showLength = 10
    //    let codePage = file.lastPathComponent.dropLast(6)
    //    let codeLine = String(format: " %04d", line)
    //    var locateCode = "\(codePage).\(function)"
    //    if locateCode.count > showLength {
    //        locateCode = locateCode.substring(from: 0, with: showLength - 3) + "..."
    //    } else {
    //        while locateCode.count < showLength { locateCode += " " }
    //    }
    //    return locateCode + codeLine
    //}()
    
    let formatThid = { () -> String in 
        var threadId: __uint64_t = 0
        pthread_threadid_np(nil, &threadId)
        return String(format: "%ld:%llu", getpid(), threadId)
    }()
    
    let formatText = String(format: format, arguments: args)
    
    print("\(formatDate) \(executable)[\(formatThid)] \(formatText)")
}

extension Int {
    
    var asFloat : Float {
        return Float(self)
    }
    
    var asString : String {
        return String(describing: self)
    }
    
    var asDouble : Double {
        return Double(self)
    }
    
    var asCGFloat : CGFloat {
        return CGFloat(self)
    }
    
    var asNSNumber : NSNumber {
        return NSNumber(integerLiteral: self)
    }
    
    /// 将整数转化为星期的描述
    var weekday : String {
        switch self {
        case 0:  return "星期日"
        case 1:  return "星期一"
        case 2:  return "星期二"
        case 3:  return "星期三"
        case 4:  return "星期四"
        case 5:  return "星期五"
        case 6:  return "星期六"
        default: return "无法解析"
        }
    }
    
    /// 将整数转化为星期的描述
    var shortWeekday : String {
        switch self {
        case 0:  return "日"
        case 1:  return "一"
        case 2:  return "二"
        case 3:  return "三"
        case 4:  return "四"
        case 5:  return "五"
        case 6:  return "六"
        default: return "无法解析"
        }
    }
    
    /// 秒数转化为时长
    var asTimeInterval : String {
        
        let hours = self / 3600
        let miniutes = self % 3600 / 60
        let seconds = self % 60
        
        var array = [String]()
        if hours > 0 {
            array.append(String(format: "%d小时", hours))
        }
        if miniutes > 0 {
            array.append(String(format: "%d分钟", miniutes))
        }
        if seconds > 0 {
            array.append(String(format: "%d秒", seconds))
        }
        
        if array.count == 0 {
            return "0秒"
        } else {
            return array.joined()
        }
    }
}

extension UInt8 {
    
    func add(_ another: UInt8) -> UInt8 {
        return UInt8((Int(self) + Int(another)) & 0x000000FF)
    }
}

extension Int32 {
    
    var asInt : Int {
        return Int(self)
    }
    
    var asString : String {
        return String(describing: self)
    }
}

extension Int64 {
    
    var asString : String {
        return String(describing: self)
    }
}

extension Bool {
    
    var asString : String {
        return String(describing: self)
    }
}

extension Float {
    
    var asString : String {
        return String(describing: self)
    }
    
    var asCGFloat : CGFloat {
        return CGFloat(self)
    }
    
    var asInt : Int {
        return Int(self)
    }
    
    var asDouble : Double {
        return Double(self)
    }
}

extension Double {
    
    var asString : String {
        return String(describing: self)
    }
    
    var asCGFloat : CGFloat {
        return CGFloat(self)
    }
    
    var asFloat : Float {
        return Float(self) 
    }
    
    var asInt : Int {
        return Int(self)
    }
}

extension CGFloat {
    
    var asString : String {
        return String(describing: self)
    }
        
    var asInt : Int {
        return Int(self)
    }
    
    var asFloat : Float {
        return Float(self)
    }
    
    var asDouble : Double {
        return Double(self)
    }
    
    var asNSNumber : NSNumber {
        return NSNumber(floatLiteral: Double(self))
    }
}

extension NSNumber {
    
    var asString : String {
        return stringValue
    }
    
    var asInt : Int {
        return intValue
    }
    
    var asBool : Bool {
        return boolValue
    }
    
    var asFloat : Float {
        return floatValue
    }

    var asDouble : Double {
        return doubleValue
    }
    
    var asCGFloat : CGFloat {
        return floatValue.asCGFloat
    }
    
    /// 将整数转化为十六进制字符串
    var hexString : String {
        return String(format: "%02x", intValue)
    }
    
    /// 将整数转化为布尔值的描述
    var boolString : String {
        return (intValue == 0) ? "false" : "true"
    }
    
    /// 将整数转化为布尔值的描述
    var BOOLString : String {
        return (intValue == 0) ? "YES" : "NO"
    }
}

enum NSPatternType : Int {
    case mobile            // 手机号码
    case phone             // 电话号码
    case email             // 电子邮箱
    case passowrd          // 密码 长度在6~32之间, 由小写字母、大写字母、阿拉伯数字、或下划线组成
    case citizenID         // 身份证号码
    case IPAddress         // IP地址
    case number            // 全是数字
    case URL               // URL地址
    case English           // 全是英文字母
    case Chinese           // 全是中文汉字
    case SMSCode           // 验证码
    case deviceName        // 设备名称
    case deviceIMEI        // 设备IMEI
    case deviceSIM         // 设备SIM
    case fenceName         // 围栏名称
    case balanceCmd        // 余额查询命令
    case remark            // 备注信息
}

extension String {
    
    var length : Int {
        return count
    }
    
    var asInt : Int {
        return Int(self) ?? 0
    }
    
    var asBool : Bool {
        let lower = lowercased()
        if lower == "true" {return true}
        if lower == "yes" {return true}
        let int = Int(self) ?? 0
        return (int != 0)
    }
    
    var asFloat : Float {
        return Float(self) ?? 0.0
    }
    
    var asDouble : Double {
        return Double(self) ?? 0.0
    }
    
    var asCGFloat : CGFloat {
        return CGFloat(asFloat)
    }
    
    var asURL : URL? {
        return URL(string: self)
    }
    
    var asFileURL : URL {
        return URL(fileURLWithPath: self)
    }
    
    /// 输出一个随机的唯一标识符
    static var UUID : String {
        return NSUUID().uuidString
    }
    
    /// 去掉字符串头尾的空格
    var trim : String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// 将String(base64格式)转为NSData
    var base64Decode : Data? {
        return Data(base64Encoded: self, options: .ignoreUnknownCharacters)
    }
    
    /// 将String以UTF8格式, 转为NSData
    var dataUsingUTF8 : Data? {
        return data(using: .utf8)
    }
    
    /// 输入类似"yyyy-MM-dd HH:mm:ss"的时间格式描述, 将String转为NSDate
    func date(using formatter: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        return dateFormatter.date(from: self)
    }
    
    /// 按照格式"yyyy-MM-dd HH:mm:ss", 将String转为NSDate
    var dateUsingDefault : Date? {
        return date(using: "yyyy-MM-dd HH:mm:ss")
    }
    
    /// "0011223344".nsrangeOf(string: "1122") = (location: 2, length: 4)
    func nsrangeOf(string: String) -> NSRange {
        return (self as NSString).range(of:string)
    }

    /// "0011223344".substring(from: 4, with: 4) = "22334"
    func substring(from location: Int, with length: Int) -> String {
        let began = index(startIndex, offsetBy: location)
        let ended = index(startIndex, offsetBy: location + length)
        return String(self[began ..< ended])
    }
    
    /// "0011223344".substring(from: 4, to: 8) = "22334"
    func substring(from aFrom: Int, to aTo: Int) -> String {
        let began = index(startIndex, offsetBy: aFrom)
        let ended = index(startIndex, offsetBy: aTo + 1)
        return String(self[began ..< ended])
    }
    
    /// "0011223344".substring(from: 4) = "223344"
    func substring(from aFrom: Int) -> String {
        let began = index(startIndex, offsetBy: aFrom)
        return String(self[began...])
    }
    
    /// "0011223344".replace(from: 4, to: 8, with: "aabbcc") = "0011aabbcc4"
    func replace(from aFrom: Int, to aTo: Int, with aWith: String) -> String {
        let began = index(startIndex, offsetBy: aFrom)
        let ended = index(startIndex, offsetBy: aTo + 1)
        return replacingCharacters(in: began ..< ended, with: aWith)
    }
    
    /// " !!sw\ni ft".regularReplace(pattern: "\\s", with: "") = "!!swift"
    func regularReplace(pattern aPattern:String, options: NSRegularExpression.Options = [], matchingOptions: NSRegularExpression.MatchingOptions = [], with replacement: String) -> String {
        let regex = try! NSRegularExpression(pattern: aPattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: matchingOptions, range: NSMakeRange(0, self.length), withTemplate: replacement)
    }
    
    /// " !!sw\ni ft".regularSearch(pattern: "sw", with: "") = "sw"
    func regularSearch(pattern aPattern:String, options: NSRegularExpression.Options = [], matchingOptions: NSRegularExpression.MatchingOptions = []) -> String? {
        let regex = try! NSRegularExpression(pattern: aPattern, options: options)
        guard let result = regex.firstMatch(in: self, options: matchingOptions, range: NSMakeRange(0, self.length)) else { return nil }
        return self.substring(from: result.range.location, with: result.range.length)
    }
    
    /// 输出本地化字符串. self是作为key输入的
    var localizedString : String {
        let nation = UserDefaults.standard.object(forKey: "AppleLanguages") as! [String] // 国家英文代码
        let folder = Bundle.main.bundlePath + "/strings.bundle" // 自定义的bundle
        let bundle = Bundle(path: folder)!
        return bundle.localizedString(forKey: self, value: nil, table: nation.first!)
    }
    
    /// 将汉字转化为拼音
    var pinyin : String {
        let ms = NSMutableString(string: self) as CFMutableString
        if CFStringTransform(ms, nil, kCFStringTransformMandarinLatin, false) {
            // ms = nǐ hǎo
        }
        if CFStringTransform(ms, nil, kCFStringTransformStripDiacritics, false) {
            // ms = ni hao
        }
        return ms as String
    }
    
    /// 判断当前字符串是否符合某种规则
    func isTypeOf(_ type: NSPatternType) -> Bool {
        
        let pattern : String
        switch type {
        case .mobile:       pattern = "^\\d{11}$"
        case .phone:        pattern = "^[0-9]{7,11}$"
        case .email:        pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        case .passowrd:     pattern = "^.{6,32}$"
        case .citizenID:    pattern = "^\\d{15}|\\d{18}$"
        case .IPAddress:    pattern = "((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)"
        case .number:       pattern = "^[0-9]*$"
        case .English:      pattern = "^[A-Za-z]+$"
        case .URL:          pattern = "\\b(([\\w-]+://?|www[.])[^\\s()<>]+(?:\\([\\w\\d]+\\)|([^[:punct:]\\s]|/)))"
        case .Chinese:      pattern = "[\\u4e00-\\u9fa5]+"
        case .SMSCode:      pattern = "^\\d{6}$"
        case .deviceName:   pattern = "^[a-zA-Z0-9_\\u4e00-\\u9fa5]{1,16}$"
        case .fenceName:    pattern = "^[a-zA-Z0-9_\\u4e00-\\u9fa5]{1,16}$"
        case .deviceIMEI:   pattern = "^[0-9]{15}$"
        case .deviceSIM:    pattern = "^\\d{11,13}$"
        case .balanceCmd:   pattern = "^[a-zA-Z0-9]{1,8}$"
        case .remark:       pattern = "^.{1,60}$"
        }
        
        let regular = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let results = regular.matches(in: self, options: .reportProgress, range: NSMakeRange(0, count))
        
        if type != .deviceIMEI {
            return results.count > 0
        }
        
        if results.count == 0 {
            return false
        } else {
            return self.isIMEI2
        }
    }
    
    /// 同NSString.lastPathComponent
    var lastPathComponent : String {
        return (self as NSString).lastPathComponent
    }
    
    var deletingLastPathComponent : String {
        return (self as NSString).deletingLastPathComponent
    }
    
    var pathExtension : String {
        return (self as NSString).pathExtension
    }
    
    var localURL : URL {
        return URL(fileURLWithPath: self)
    }
    
    /// 将十六进制字符串转成数值类型. eg: "FF" -> 255
    var asHexNumber : UInt32 {
        let str = uppercased()
        var sum : UInt32 = 0
        for i in str.utf8 {
            sum = sum * 16 + UInt32(i) - 48 // 0-9 从48开始
            if i >= 65 { sum -= 7 }      // A-Z 从65开始，但有初始值10，所以应该是减去55
        }
        return sum
    }
    
    /// IMEI是国际移动通讯设备识别号(International Mobile Equipment Identity)的缩写，用于GSM系统。
    ///
    /// 由15位数字组成，前6位(TAC)是型号核准号码，代表手机类型。接着2位(FAC)是最后装配号，代表产地。后6位(SNR)是串号，代表生产顺序号。最后1位(SP)是检验码。 IMEI校验码算法：
    /// ```
    /// 1) 将偶数位数字分别乘以2，分别计算个位数和十位数之和
    /// 2) 将奇数位数字相加，再加上上一步算得的值
    /// 3) 如果得出的数个位是0则校验位为0，否则为10减去个位数
    /// 如：35 89 01 80 69 72 41 偶数位乘以2得到5*2=10 9*2=18 1*2=02 0*2=00 9*2=18 2*2=04 1*2=02,计算奇数位数字之和和偶数位个位十位之和，得到 3+(1+0)+8+(1+8)+0+(0+2)+8+(0+0)+6+(1+8)+7+(0+4)+4+(0+2)=63 => 校验位 10-3 = 7
    var isIMEI : Bool {
        
        guard let characters = self.cString(using: .utf8) else {
            return false
        }
        
        let length = characters.count - 1
        if length != 15 {
            return false
        }
        
        let half = length / 2 - 1
        
        var sum = 0
        for i in 0 ... half {
            let a =  characters[2 * i + 0] - 48
            let b = (characters[2 * i + 1] - 48) * 2
            let c = (b < 10) ? b : (b - 9)
            sum += Int(a) + Int(c) // Int8 + Int8 will overflow
        }
        sum %= 10
        sum = (sum == 0) ? 0 : (10 - sum)
        
        return (characters[length - 1] - 48) == sum
    }
    
    /// 校验IMEI
    var isIMEI2 : Bool {
        
        if self.count < 15 {
            return false
        }
        
        let last = self.unicodeScalars.last!
        let left = self.dropLast().unicodeScalars
        
        var sum : UInt32 = 0
        for (offset, element) in left.enumerated() {
            var v = element.value - 48
            if offset % 2 != 0 {
                let a = v * 2
                v = (a < 10) ? a : (a - 9)
            }
            sum += v
        }
        sum %= 10
        sum = (sum == 0) ? 0 : (10 - sum)
        
        return (last.value - 48) == sum
    }
}

extension NSRegularExpression {
    
    /// convenience
    func stringByReplacingMatches(in string: String, options: NSRegularExpression.MatchingOptions = [], withTemplate templ: String) -> String {
        return self.stringByReplacingMatches(in: string, options: options, range: NSMakeRange(0, string.count), withTemplate: templ)
    }
}

extension String.Encoding {
    
    /// GB18030
    public static var GB18030: String.Encoding  = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)))
}

extension Date {
    
    /// 将Date以某种格式转化为字符串
    func string(using formatter: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        return dateFormatter.string(from: self)
    }
    
    /// 将Date以预定格式转化为字符串
    var stringUsingDefault : String {
        return self.string(using: "yyyy-MM-dd HH:mm:ss")
    }
}

class NSTimePeriod: NSObject {
    
    /// 开始时刻
    var began : Date?
    
    /// 结束时刻
    var ended : Date?
    
    /// 持续时长
    var timeInterval : TimeInterval? {
        if let b = began, let e = ended {
            return e.timeIntervalSince(b)
        }
        return nil
    }
    
    /// 深拷贝
    func clone() -> NSTimePeriod {
        let obj = NSTimePeriod()
        obj.began = self.began
        obj.ended = self.ended
        return obj
    }
}

extension Data {

    /// 将Data按照某种编码格式, 转为String
    func string(using encoding: String.Encoding) -> String? {
        return String(data: self, encoding: encoding)
    }
        
    /// 将Data以UTF8格式, 转为String
    var stringUsingUTF8 : String? {
        return String(data: self, encoding: .utf8)
    }

    /// 依次使用'GB18030 > utf8', 进行尝试, Data转为String
    var stringUsingAuto : String? {
        let encodings : [String.Encoding] = [.utf8, .GB18030]
        for encoding in encodings {
            if let string = String(data: self, encoding: encoding) {
                return string
            }
        }
        return nil
    }
    
    /// 将NSData转为String(base64格式)
    var base64Encode : String {
        return self.base64EncodedString(options: .lineLength64Characters)
    }
    
    /// 将NSData(json内容)转成AnyObject(其实是Array或者Dictionary)
    var asJSONObject : Any? {
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: self, options: .mutableLeaves)
            return jsonObject
        } catch {
            NSLog("%@ error=%@", #function, error.localizedDescription)
            return nil
        }
    }
    
    /// 将Data转为JSON
    var asJSON : JSON {
        return JSON(self)
    }
    
    /// 将NSData转成十六进制字符串
    var hexString : String {
        return self.reduce("", { $0.appendingFormat("%02x", $1) })
    }
}

extension Array {
    
    var asJSONString : String? {
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions(rawValue: 0))
            let jsonText = String(data: jsonData, encoding: .utf8)
            return jsonText
        }
        catch {
            NSLog("%@ error = %@", #function, error.localizedDescription)
            return nil
        }
    }
}

extension Dictionary {
    
    var asJSONString : String? {
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions(rawValue: 0))
            let jsonText = String(data: jsonData, encoding: .utf8)
            return jsonText
        }
        catch {
            NSLog("%@ error = %@", #function, error.localizedDescription)
            return nil
        }
    }
}

extension URL {

    /// download
    func download() throws -> Data {
        return try Data(contentsOf: self)
    }
}

extension Bundle {
    
    /// 输出Bundle版本
    static var shortVersion : String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    /// 输出Build版本
    static var buildVersion : String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }
    
    /// 输出Bundle目录
    static var bundleDirectory : String {
        return Bundle.main.bundlePath
    }
    
    /// 输出home目录
    static var homeDirectory : String {
        return NSHomeDirectory()
    }
    
    /// 输出document目录
    static var documentDirectory : String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }
    
    /// 输出temporary目录
    static var temporaryDirectory : String {
        return NSTemporaryDirectory()
    }
    
    /// 输出自定义目录
    static var customDirectory : String {
        let dstPath = NSHomeDirectory().appending("/custom")
        let fileManager = FileManager.default
        if fileManager.existsDirectory(at: dstPath) == nil {
            return fileManager.createDirectory(at: dstPath)!
        }
        return dstPath
    }
    
    /// 日志输出重定向
    static func redirectNSlogToDocumentFolder(_ filename: String) {
        let logFilePath = Bundle.documentDirectory.appendingFormat("/%@", filename)
        try? FileManager.default.removeItem(atPath: logFilePath)
        freopen(logFilePath.cString(using: .ascii), "w+", stdout)
        freopen(logFilePath.cString(using: .ascii), "w+", stderr)
    }
}

extension FileManager {
    
    func existsDirectory(at path: String) -> String? {
        
        var isDirectory = ObjCBool(false)
        
        let isExists = self.fileExists(atPath: path, isDirectory: &isDirectory)
        
        if isExists == false {
            return nil
        }
        
        if isDirectory.boolValue == false {
            return nil
        }
        
        return path
    }
    
    func createDirectory(at path: String) -> String? {
        
        var isDirectory = ObjCBool(false)
        
        let isExists = self.fileExists(atPath: path, isDirectory: &isDirectory)
        
        if isExists {
            return nil
        }
        
        if isDirectory.boolValue {
            return nil
        }
        
        do {
            try self.createDirectory(atPath: path, withIntermediateDirectories: true)
        } catch {
            return nil
        }
        
        return path
    }
    
    func removeDirectory(at path: String) -> String? {
        
        do {
            try self.removeItem(atPath: path)
        } catch {
            return nil
        }
        
        return path
    }
    
    func existsFile(at path: String) -> String? {
        
        var isDirectory = ObjCBool(false)
        
        let isExists = self.fileExists(atPath: path, isDirectory: &isDirectory)
        
        if isExists == false {
            return nil
        }
        
        if isDirectory.boolValue == true {
            return nil
        }
        
        return path
    }
    
    @discardableResult
    func removeFile(at path: String) -> String? {
        
        do {
            try self.removeItem(atPath: path)
        } catch {
            return nil
        }
        
        return path
    }
}

func dispatch_asyn_on_main(execute: @escaping () -> Void) {
    
    if Thread.isMainThread {
        execute()
    } else {
        DispatchQueue.main.async(execute: execute)
    }
}

fileprivate let kPriorityDefaultGlobalQueueValue = "kPriorityDefaultGlobalQueueKeyValue"
fileprivate let kPriorityDefaultGlobalQueueKey = DispatchSpecificKey<String>.init()

func dispatch_asyn_on_global(execute: @escaping () -> Void) {
    
    if let value = DispatchQueue.getSpecific(key: kPriorityDefaultGlobalQueueKey), value == kPriorityDefaultGlobalQueueValue {
        execute()
    } else {
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        queue.setSpecific(key: kPriorityDefaultGlobalQueueKey, value: kPriorityDefaultGlobalQueueValue)
        queue.async(execute: execute)
    }
}
