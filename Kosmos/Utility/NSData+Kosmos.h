//
//  NSData+Kosmos.h
//  mxt1608s
//
//  Created by weizhen on 2017/1/12.
//  Copyright © 2017年 Wuhan Mengxin Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Kosmos)

/** 将NSData编码为NSData(MD5格式) */
- (NSData *)md5;

/** 将NSData编码为NSData(SHA1格式) */
- (NSData *)sha1;

/** 使用key(>=8bytes), 对NSData编码(kCCEncrypt)或解码(kCCDecrypt) */
- (NSData *)des:(BOOL)isEncrypt key:(NSData *)key;

@end
