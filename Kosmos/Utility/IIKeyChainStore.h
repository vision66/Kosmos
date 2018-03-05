//
//  IIKeyChainStore.h
//  campus
//
//  Created by weizhen on 2017/6/19.
//  Copyright © 2017年 whmx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IIKeyChainStore : NSObject

+ (void)save:(NSString *)service data:(id)data;

+ (id)load:(NSString *)service;

+ (void)deleteKeyData:(NSString *)service;

@end

extern NSString * getUUID(void);
