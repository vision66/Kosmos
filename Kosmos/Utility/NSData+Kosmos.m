//
//  NSData+Silence9x.m
//  mxt1608s
//
//  Created by weizhen on 2017/1/12.
//  Copyright © 2017年 Wuhan Mengxin Technology Co., Ltd. All rights reserved.
//

#import "NSData+Kosmos.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSData (Kosmos)

/** 将NSData编码为NSData(MD5格式) */
- (NSData *)md5 {
    NSMutableData *result = [NSMutableData dataWithLength:CC_MD5_DIGEST_LENGTH];
    CC_MD5(self.bytes, (CC_LONG)self.length, result.mutableBytes);
    return result;
}

/** 将NSData编码为NSData(SHA1格式) */
- (NSData *)sha1 {
    NSMutableData *result = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(self.bytes, (CC_LONG)self.length, result.mutableBytes);
    return result;
}

/** 使用key(>=8bytes), 对NSData编码(kCCEncrypt)或解码(kCCDecrypt), http://tool.chacuo.net/cryptdes */
- (NSData *)des:(BOOL)isEncrypt key:(NSData *)key {
    
    NSData        *keyData = key;
    NSInteger    keyLength = (size_t)kCCKeySizeDES;
    
    CCOperation  operation = isEncrypt ? kCCEncrypt : kCCDecrypt;
    CCAlgorithm   algoritm = kCCAlgorithmDES;
    CCOptions      options = kCCOptionECBMode | kCCOptionPKCS7Padding;
    
    NSMutableData *dataOut = [NSMutableData dataWithLength:self.length + kCCBlockSizeAES128];
    size_t    dataOutMoved = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(operation,            //加密(解密)模式 kCCEncrypt:加密, kCCDecrypt:解密
                                          algoritm,             //加密(解密)方式
                                          options,              //填充算法
                                          keyData.bytes,        //密钥(超出密钥长度的部分将被忽略)
                                          keyLength,            //密钥长度
                                          nil,                  //初始化向量
                                          self.bytes,           //待加密(待解密)的数据
                                          self.length,          //待加密(待解密)的数据长度
                                          dataOut.mutableBytes, //将输出的已加密(已解密)数据的缓冲区
                                          dataOut.length,       //将输出的已加密(已解密)数据的缓冲区长度
                                          &dataOutMoved);       //将输出的已加密(已解密)数据的实际长度
    
    if (cryptStatus == kCCSuccess) {
        dataOut.length = dataOutMoved;
        return dataOut;
    } else {
        NSLog(@"%s error = %d", __func__, cryptStatus);
        return nil;
    }
}

@end
