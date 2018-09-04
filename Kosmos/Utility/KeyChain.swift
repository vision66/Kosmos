//
//  KeyChain.swift
//  mxt1609s
//
//  Created by weizhen on 2018/4/19.
//  Copyright © 2018年 Wuhan Mengxin Technology Co., Ltd. All rights reserved.
//

import Foundation

/// @see https://www.jianshu.com/p/9e885c3e6b0a
class KeyChain: NSObject {

    static let shared = KeyChain()
    
    func guery(service: String) -> NSMutableDictionary {
        let item = NSMutableDictionary()
        item.setObject(kSecClassInternetPassword as NSString, forKey: kSecClass as NSString)
        item.setObject(service as NSString, forKey: kSecAttrServer as NSString)
        item.setObject(service as NSString, forKey: kSecAttrAccount as NSString)
        item.setObject(kSecAttrAccessibleAfterFirstUnlock as NSString, forKey: kSecAttrAccessible as NSString)
        return item
    }
    
    func save(service: String, data: String) {
        let keychainQuery = guery(service: service)
        SecItemDelete(keychainQuery);
        keychainQuery.setObject(data.dataUsingUTF8!, forKey: kSecValueData as NSString)
        SecItemAdd(keychainQuery, nil)
    }

    func load(service: String) -> String? {
        let keychainQuery = guery(service: service)
        keychainQuery.setObject(kCFBooleanTrue, forKey: kSecReturnData as NSString)
        keychainQuery.setObject(kSecMatchLimit as NSString, forKey: kSecMatchLimitOne as NSString)
        var keyData : AnyObject? = nil
        SecItemCopyMatching(keychainQuery, &keyData)
        return (keyData as? Data)?.stringUsingUTF8
    }
    
    func deleteKeyData(service: String) {
        let keychainQuery = guery(service: service)
        SecItemDelete(keychainQuery)
    }
}

func getUUID(_ clientKey: String) -> String {
    
    // 钥匙串中找到了uuid
    if let uuid = KeyChain.shared.load(service: clientKey), uuid.count > 0 {
        return uuid
    }
    
    // 生成一个uuid的方法
    let uuidRef = CFUUIDCreate(nil)
    let uuidStr = CFUUIDCreateString(nil, uuidRef)! as String
    let uuid = uuidStr.replacingOccurrences(of: "-", with: "")
    
    // 将该uuid保存到keychain
    KeyChain.shared.save(service: clientKey, data: uuid)
    
    return uuid
}
