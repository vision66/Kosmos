//
//  Data+CommonCrypto.swift
//  student
//
//  Created by weizhen on 2019/1/30.
//  Copyright © 2019 Wuhan Mengxin Technology Co., Ltd. All rights reserved.
//

import Foundation
import CommonCrypto

extension Data {
    
    /** 将NSData编码为NSData(MD5格式) */
    var md5 : Data {
        let dataLength = self.count
        let dataBuffer = [UInt8](self)
        let digestLength = Int(CC_MD5_DIGEST_LENGTH)
        let digestBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: digestLength)
        CC_MD5(dataBuffer, UInt32(dataLength), digestBuffer)
        let result = Data(bytes: digestBuffer, count: digestLength)
        digestBuffer.deallocate()
        return result
    }
    
    /** 将NSData编码为NSData(SHA1格式) */
    var sha1 : Data {
        let dataLength = self.count
        let dataBuffer = [UInt8](self)
        let digestLength = Int(CC_SHA1_DIGEST_LENGTH)
        let digestBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: digestLength)
        CC_SHA1(dataBuffer, UInt32(dataLength), digestBuffer)
        let result = Data(bytes: digestBuffer, count: digestLength)
        digestBuffer.deallocate()
        return result
    }
    
    /** 使用key(>=8bytes), 对NSData编码(kCCEncrypt)或解码(kCCDecrypt), http://tool.chacuo.net/cryptdes */
    func des(isEncrypt: Bool, key: Data) -> Data? {
        
        let operation = isEncrypt ? kCCEncrypt : kCCDecrypt
        let algoritm = kCCAlgorithmDES
        let options = kCCOptionECBMode | kCCOptionPKCS7Padding
        let keyData = [UInt8](key)
        let keyLength = kCCKeySizeDES
        let dataIn = [UInt8](self)
        let dataInLength = self.count
        let dataOutAvailable = dataInLength + kCCBlockSizeDES
        let dataOut = UnsafeMutablePointer<UInt8>.allocate(capacity: dataOutAvailable)
        var dataOutMoved = 0
        
        let cryptStatus = CCCrypt(
            CCOperation(operation), //加密(解密)模式 kCCEncrypt:加密, kCCDecrypt:解密
            CCAlgorithm(algoritm),  //加密(解密)方式
            CCOptions(options),     //填充算法
            keyData,                //密钥(超出密钥长度的部分将被忽略)
            keyLength,              //密钥长度
            nil,                    //初始化向量
            dataIn,                 //待加密(待解密)的数据
            dataInLength,           //待加密(待解密)的数据长度
            dataOut,                //将输出的已加密(已解密)数据的缓冲区
            dataOutAvailable,       //将输出的已加密(已解密)数据的缓冲区长度
            &dataOutMoved)          //将输出的已加密(已解密)数据的实际长度
        
        if cryptStatus == kCCSuccess {
            let result = Data(bytes: dataOut, count: dataOutMoved)
            dataOut.deallocate()
            return result
        } else {
            print("\(#function) error = \(cryptStatus)")
            dataOut.deallocate()
            return nil
        }
    }
}
