//
//  IIContacts.h
//  mxt1608s
//
//  Created by weizhen on 2017/5/4.
//  Copyright © 2017年 whmx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** 联系人的Email对象 */
@interface ZHContacterEmail : NSObject

/** 邮件的描述(如住宅、iCloud..) */
@property (nonatomic, copy) NSString *title;

/** 邮件的地址(如....@iCloud.cn) */
@property (nonatomic, copy) NSString *address;

@end

/** 联系人的电话对象 */
@interface ZHContacterPhone : NSObject

/** 电话描述(如住宅，工作..) */
@property (nonatomic, copy) NSString *title;

/** 电话号码 */
@property (nonatomic, copy) NSString *number;

@end

/** 联系人的地址信息 */
@interface ZHContacterAddress : NSObject

/** 地址的标签(比如住宅、工作...) */
@property (nonatomic, copy) NSString *addressTitle;

/** 街道 */
@property (nonatomic, copy) NSString *street;

/** 城市 */
@property (nonatomic, copy) NSString *city;

/** 省(州) */
@property (nonatomic, copy) NSString *state;

/** 邮编 */
@property (nonatomic, copy) NSString *postalCode;

/** 国家 */
@property (nonatomic, copy) NSString *country;

/** ISO国家编号 */
@property (nonatomic, copy) NSString *ISOCountryCode;

@end

/**  联系人的即时通信对象 */
@interface ZHContacterInstantMessage : NSObject

/** 服务名称(如QQ) */
@property (nonatomic, copy) NSString *service;

/** 服务账号(如QQ号) */
@property (nonatomic, copy) NSString *userName;

@end

/** 联系人的关联对象 */
@interface ZHContacterRelated : NSObject

/** 关联的标签(如friend) */
@property (nonatomic, copy) NSString *title;

/** 关联的名称(如联系人姓名) */
@property (nonatomic, copy) NSString *name;

@end

/** 联系人的社交简介对象 */
@interface ZHContacterSocialProfile : NSObject

/** 社交简介(如sinaweibo) */
@property (nonatomic, copy) NSString *title;

/** 社交地址(123456) */
@property (nonatomic, copy) NSString *account;

/** 社交链接的地址(按照上面两项自动为http://weibo.com/n/123456) */
@property (nonatomic, copy) NSString *url;

@end

/** 联系人对象 */
@interface ZHContacter : NSObject

/** 姓名 */
@property (nonatomic, copy) NSString *fullName;

/** 昵称 */
@property (nonatomic, copy) NSString *nickName;

/** 名字 */
@property (nonatomic, copy) NSString *givenName;

/** 姓氏 */
@property (nonatomic, copy) NSString *familyName;

/** 英文名字中间存的信仰缩写字母(X·Y·Z的Y) */
@property (nonatomic, copy) NSString *middleName;

/** 名字的前缀 */
@property (nonatomic, copy) NSString *namePrefix;

/** 名字的后缀 */
@property (nonatomic, copy) NSString *nameSuffix;

/** 名字的拼音音标 */
@property (nonatomic, copy) NSString *phoneticGivenName;

/** 姓氏的拼音音标 */
@property (nonatomic, copy) NSString *phoneticFamilyName;

/** 英文名字中间存的信仰缩写字母的拼音音标 */
@property (nonatomic, copy) NSString *phoneticMiddleName;

/** 联系人的类型. 0 个人; 1 公司 */
@property (nonatomic, assign) NSUInteger type;

/** 联系人的头像 */
@property (nonatomic, strong) UIImage *headImage;

/** 公司(组织) */
@property (nonatomic, copy) NSString *organizationName;

/** 部门 */
@property (nonatomic, copy) NSString *departmentName;

/** 职位 */
@property (nonatomic, copy) NSString *jobTitle;

/** 生日日历的识别码 */
@property (nonatomic, strong) NSDate *brithdayDate;

/** 农历生日?????? */
@property (nonatomic, strong) NSDateComponents *alternateBirthday;

/** 备注 */
@property (nonatomic, copy) NSString *note;

/** 创建日期 */
@property (nonatomic, strong) NSDate *createDate;

/** 最近一次修改的时间 */
@property (nonatomic, strong) NSDate *modifyDate;

/** 联系人的电话对象 */
@property (nonatomic, copy) NSArray <ZHContacterPhone *> *phones;

/** 联系人的邮箱地址 */
@property (nonatomic, copy) NSArray <ZHContacterEmail *> *emails;

/** 联系人的地址对象 */
@property (nonatomic, copy) NSArray <ZHContacterAddress *> *addresses;

/** 联系人的即时工具 */
@property (nonatomic, copy) NSArray <ZHContacterInstantMessage *> *instantMessage;

/** 联系人的关联对象 */
@property (nonatomic, copy) NSArray <ZHContacterRelated *> *relatedNames;

/** 联系人的社交简介 */
@property (nonatomic, copy) NSArray <ZHContacterSocialProfile *> *socialProfiles;

@end

extern NSString *const kContactsDidGrantedNotification;

extern NSString *const kContactsDidUpdatedNotification;

extern NSString *const kContactsGrantedKey;

typedef NS_ENUM(NSInteger, IIContactsAuthorizationStatus) {
    IIContactsAuthorizationStatusNotDetermined = 0,
    IIContactsAuthorizationStatusRestricted,
    IIContactsAuthorizationStatusDenied,
    IIContactsAuthorizationStatusAuthorized
};

@interface IIContacts : NSObject

+ (instancetype)sharedInstance;

- (IIContactsAuthorizationStatus)authorizationStatus;

- (void)requestAuthorization;

- (NSArray<ZHContacter *> *)contacts;

@end
