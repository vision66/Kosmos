//
//  IIContacts.m
//  mxt1608s
//
//  Created by weizhen on 2017/5/4.
//  Copyright © 2017年 whmx. All rights reserved.
//

#import "IIContacts.h"
#import <AddressBook/AddressBook.h>
#import "dispatch+Kosmos.h"

@implementation ZHContacterPhone

@end

@implementation ZHContacterEmail

@end

@implementation ZHContacterAddress

@end

@implementation ZHContacterInstantMessage

@end

@implementation ZHContacterRelated

@end

@implementation ZHContacterSocialProfile

@end

@interface ZHContacter()

@property (nonatomic, assign) ABRecordRef recordRef;

@end

#define CFSafeRelease(ptr) if(ptr){CFRelease(ptr);}

@implementation ZHContacter

/** 根据ABRecordRef数据获得YContantObject对象 */
- (instancetype)initWithRecord:(ABRecordRef)recordRef {
    
    self = [super init];
    
    if (self) {
        
        // ABRecordRef对象
        self.recordRef = recordRef;
        
        self.fullName = CFBridgingRelease(ABRecordCopyCompositeName(self.recordRef));                 //全名
        self.givenName = [self contactPropertyAsString:kABPersonFirstNameProperty];                   //名字
        self.familyName = [self contactPropertyAsString:kABPersonLastNameProperty];                   //姓氏
        self.middleName = [self contactPropertyAsString:kABPersonMiddleNameProperty];                 //名字中的信仰名称
        self.namePrefix = [self contactPropertyAsString:kABPersonPrefixProperty];                     //名字前缀
        self.nameSuffix = [self contactPropertyAsString:kABPersonSuffixProperty];                     //名字后缀
        self.nickName = [self contactPropertyAsString:kABPersonNicknameProperty];                     //名字昵称
        self.phoneticGivenName = [self contactPropertyAsString:kABPersonFirstNamePhoneticProperty];   //名字的拼音音标
        self.phoneticFamilyName = [self contactPropertyAsString:kABPersonLastNamePhoneticProperty];   //姓氏的拼音音标
        self.phoneticMiddleName = [self contactPropertyAsString:kABPersonMiddleNamePhoneticProperty]; //英文信仰缩写字母的拼音音标
        
        self.organizationName = [self contactPropertyAsString:kABPersonOrganizationProperty];   //公司(组织)名称
        self.departmentName = [self contactPropertyAsString:kABPersonDepartmentProperty];       //部门
        self.jobTitle = [self contactPropertyAsString:kABPersonJobTitleProperty];               //职位
        
        self.type = [self contactTypeProperty];                                     // 联系人类型
        self.headImage = [self contactHeadImagePropery];                            //头像
        self.brithdayDate = [self contactPropertyAsDate:kABPersonBirthdayProperty]; //生日的日历
        
        //获得农历日历属性的字典, 农历日历的属性，设置为农历属性的时候，此字典存在数值
        self.alternateBirthday = [self contactAlternateBirthdayPropery];
        
        //备注
        self.note = [self contactPropertyAsString:kABPersonNoteProperty];
        
        //创建时间
        self.createDate = [self contactPropertyAsDate:kABPersonCreationDateProperty];
        
        //最近一次修改的时间
        self.modifyDate = [self contactPropertyAsDate:kABPersonModificationDateProperty];
        
        //邮件对象
        self.emails = [self contactEmailProperty];
        
        //地址对象
        self.addresses = [self contactAddressProperty];
        
        //电话对象
        self.phones = [self contactPhoneProperty];
        
        //即时通信对象
        self.instantMessage = [self contactMessageProperty];
        
        //关联对象
        self.relatedNames = [self contactRelatedNamesProperty];
        
        //社交简介
        self.socialProfiles = [self contactSocialProfilesProperty];
    }
    
    return self;
}

/** 根据属性key获得NSString */
- (NSString *)contactPropertyAsString:(ABPropertyID)property {
    return CFBridgingRelease((ABRecordCopyValue(self.recordRef, property)));
}

/** 根据属性key获得NSDate */
- (NSDate *)contactPropertyAsDate:(ABPropertyID)property {
    return CFBridgingRelease((ABRecordCopyValue(self.recordRef, property)));
}

/** 获得联系人的头像图片 */
- (UIImage *)contactHeadImagePropery {
    
    //首先判断是否存在头像
    if (ABPersonHasImageData(self.recordRef) == false) {
        return nil;
    }
    
    //开始获得头像信息
    NSData *imageData = CFBridgingRelease(ABPersonCopyImageData(self.recordRef));
    
    //获得头像原图
    //NSData *imageData = CFBridgingRelease(ABPersonCopyImageDataWithFormat(self.recordRef, kABPersonImageFormatOriginalSize));
    
    return [UIImage imageWithData:imageData];
}

/** 农历生日?????? */
- (NSDateComponents *)contactAlternateBirthdayPropery {
    NSDictionary *dictionary = CFBridgingRelease(ABRecordCopyValue(self.recordRef, kABPersonAlternateBirthdayProperty));
    if (dictionary == nil)
        return nil;
    NSDateComponents *components = [NSDateComponents new];
    components.calendar = [NSCalendar calendarWithIdentifier:dictionary[(__bridge NSString *)kABPersonAlternateBirthdayCalendarIdentifierKey]]; //农历生日的标志位,比如“chinese”
    components.era = [dictionary[(__bridge NSString *)kABPersonAlternateBirthdayEraKey] integerValue];                //纪元
    components.year = [dictionary[(__bridge NSString *)kABPersonAlternateBirthdayYearKey] integerValue];              //年份,六十组干支纪年的索引数，比如12年为壬辰年，为循环的29,此数字为29
    components.month = [dictionary[(__bridge NSString *)kABPersonAlternateBirthdayMonthKey] integerValue];            //月份
    components.leapMonth = [dictionary[(__bridge NSString *)kABPersonAlternateBirthdayIsLeapMonthKey] boolValue];     //是否是闰月
    components.day = [dictionary[(__bridge NSString *)kABPersonAlternateBirthdayDayKey] integerValue];                //日期
    return components;
}

/** 获得联系人类型信息 */
- (NSUInteger)contactTypeProperty {
    
    // 获得类型属性
    CFNumberRef typeIndex = ABRecordCopyValue(self.recordRef, kABPersonKindProperty);
    
    // 表示是公司联系人
    CFComparisonResult result = CFNumberCompare(typeIndex, kABPersonKindOrganization, nil);
    CFRelease(typeIndex);
    
    return (result == kCFCompareEqualTo) ? 1 : 0;
}

/** 获得Email对象的数组 */
- (NSArray<ZHContacterEmail *> *)contactEmailProperty {
    
    //外传数组
    NSMutableArray <ZHContacterEmail *> *emails = [NSMutableArray array];
    
    //获取多值属性
    ABMultiValueRef values = ABRecordCopyValue(self.recordRef, kABPersonEmailProperty);
    
    //遍历添加
    for (CFIndex i = 0; i < ABMultiValueGetCount(values); i++) {
        ZHContacterEmail *email = [[ZHContacterEmail alloc] init];
        CFStringRef string = ABMultiValueCopyLabelAtIndex(values, i);
        email.title = CFBridgingRelease(ABAddressBookCopyLocalizedLabel(string));      //邮件描述
        CFSafeRelease(string);
        email.address = CFBridgingRelease(ABMultiValueCopyValueAtIndex(values, i));    //邮件地址
        [emails addObject:email];
    }
    
    //释放资源
    CFRelease(values);
    return emails;
}

/** 获得电话号码对象数组 */
- (NSArray<ZHContacterPhone *> *)contactPhoneProperty {
    
    //外传数组
    NSMutableArray <ZHContacterPhone *> *phones = [NSMutableArray array];
    
    //获得电话号码的多值对象
    ABMultiValueRef values = ABRecordCopyValue(self.recordRef, kABPersonPhoneProperty);
    
    for (CFIndex i = 0; i < ABMultiValueGetCount(values); i++) {
        ZHContacterPhone *phone = [[ZHContacterPhone alloc] init];
        CFStringRef string = ABMultiValueCopyLabelAtIndex(values, i);
        phone.title = CFBridgingRelease(ABAddressBookCopyLocalizedLabel(string)); //电话描述(如住宅、工作..)
        CFSafeRelease(string);
        phone.number = CFBridgingRelease(ABMultiValueCopyValueAtIndex(values, i)); //电话号码
        [phones addObject:phone];
    }
    
    //释放资源
    CFRelease(values);
    return phones;
}

/** 获得联系人的关联人信息 */
- (NSArray<ZHContacterRelated *> *)contactRelatedNamesProperty {
    
    //存放数组
    NSMutableArray <ZHContacterRelated *> *relatedNames = [NSMutableArray array];
    
    //获得多值属性
    ABMultiValueRef values = ABRecordCopyValue(self.recordRef, kABPersonRelatedNamesProperty);
    
    //遍历赋值
    for (CFIndex i = 0; i < ABMultiValueGetCount(values); i++) {
        ZHContacterRelated *related = [[ZHContacterRelated alloc] init];
        CFStringRef string = ABMultiValueCopyLabelAtIndex(values, i);
        related.title = CFBridgingRelease(ABAddressBookCopyLocalizedLabel(string)); //关联的标签(如friend)
        CFSafeRelease(string);
        related.name = CFBridgingRelease(ABMultiValueCopyValueAtIndex(values, i));                                   //关联的名称(如联系人姓名)
        [relatedNames addObject:related];
    }
    
    CFRelease(values);
    return relatedNames;
}

/** 获得即时通信账号相关信息 */
- (NSArray<ZHContacterInstantMessage *> *)contactMessageProperty {
    
    //存放数组
    NSMutableArray <ZHContacterInstantMessage *> *instantMessages = [NSMutableArray array];
    
    //获取数据字典
    ABMultiValueRef values = ABRecordCopyValue(self.recordRef, kABPersonInstantMessageProperty);
    
    //遍历获取值
    for (CFIndex i = 0; i < ABMultiValueGetCount(values); i++) {
        
        NSDictionary *dictionary = CFBridgingRelease(ABMultiValueCopyValueAtIndex(values, i));
        
        ZHContacterInstantMessage *instantMessage = [[ZHContacterInstantMessage alloc] init];
        
        instantMessage.service = [dictionary valueForKey:@"service"];          //服务名称(如QQ)
        instantMessage.userName = [dictionary valueForKey:@"username"];        //服务账号(如QQ号)
        
        [instantMessages addObject:instantMessage];
    }
    
    CFRelease(values);
    return instantMessages;
}

/** 获得联系人的社交简介信息 */
- (NSArray<ZHContacterSocialProfile *> *)contactSocialProfilesProperty {
    
    //外传数组
    NSMutableArray <ZHContacterSocialProfile *> *socialProfiles = [NSMutableArray array];
    
    //获得多值属性
    ABMultiValueRef values = ABRecordCopyValue(self.recordRef, kABPersonSocialProfileProperty);
    
    //遍历取值
    for (CFIndex i = 0; i < ABMultiValueGetCount(values); i++) {
        
        NSDictionary *dictionary = CFBridgingRelease(ABMultiValueCopyValueAtIndex(values, i));
        
        ZHContacterSocialProfile *socialProfile = [[ZHContacterSocialProfile alloc] init];
        
        socialProfile.title = [dictionary valueForKey:@"service"];    //社交简介(如sinaweibo)
        socialProfile.account = [dictionary valueForKey:@"username"]; //社交地址(如123456)
        socialProfile.url = [dictionary valueForKey:@"url"];          //社交链接的地址(按照上面两项自动为http://weibo.com/n/123456)
        
        [socialProfiles addObject:socialProfile];
    }
    
    CFRelease(values);
    return socialProfiles;
}

/** 获得Address对象的数组 */
- (NSArray<ZHContacterAddress *> *)contactAddressProperty {
    
    //外传数组
    NSMutableArray <ZHContacterAddress *> *addresses = [NSMutableArray array];
    
    //获取多指属性
    ABMultiValueRef values = ABRecordCopyValue(self.recordRef, kABPersonAddressProperty);
    
    //遍历添加
    for (CFIndex i = 0; i < ABMultiValueGetCount(values); i++) {
        
        ZHContacterAddress *address = [[ZHContacterAddress alloc] init];
        
        //地址标签
        CFStringRef string = ABMultiValueCopyLabelAtIndex(values, i);
        address.addressTitle = CFBridgingRelease(ABAddressBookCopyLocalizedLabel(string));
        CFSafeRelease(string);
        
        //获得属性字典
        NSDictionary *dictionary = CFBridgingRelease(ABMultiValueCopyValueAtIndex(values, i));
        address.country = [dictionary valueForKey:(__bridge NSString *)kABPersonAddressCountryKey];               //国家
        address.city = [dictionary valueForKey:(__bridge NSString *)kABPersonAddressCityKey];                     //城市
        address.state = [dictionary valueForKey:(__bridge NSString *)kABPersonAddressStateKey];                   //省(州)
        address.street = [dictionary valueForKey:(__bridge NSString *)kABPersonAddressStreetKey];                 //街道
        address.postalCode = [dictionary valueForKey:(__bridge NSString *)kABPersonAddressZIPKey];                //邮编
        address.ISOCountryCode = [dictionary valueForKey:(__bridge NSString *)kABPersonAddressCountryCodeKey];    //ISO国家编号
        
        [addresses addObject:address];
    }
    
    //释放资源
    CFRelease(values);
    return addresses;
}

@end

NSString *const kContactsDidGrantedNotification = @"notification.contacts.DidGranted";

NSString *const kContactsDidUpdatedNotification = @"notification.contacts.DidUpdated";

NSString *const kContactsGrantedKey = @"granted";

@implementation IIContacts {
    ABAddressBookRef _addressBook;
}

static void ABAddressBookExternalChangeCallbackxxxx(ABAddressBookRef addressBook, CFDictionaryRef info, void *context) {
    [NSNotificationCenter.defaultCenter postNotificationName:kContactsDidUpdatedNotification object:nil userInfo:nil];
}

+ (instancetype)sharedInstance {
    static IIContacts *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [IIContacts.alloc init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    _addressBook = ABAddressBookCreate();
    ABAddressBookRegisterExternalChangeCallback(_addressBook, ABAddressBookExternalChangeCallbackxxxx, NULL);
    return self;
}

- (IIContactsAuthorizationStatus)authorizationStatus {
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    switch (status) {
        case kABAuthorizationStatusAuthorized:      return IIContactsAuthorizationStatusAuthorized;
        case kABAuthorizationStatusDenied:          return IIContactsAuthorizationStatusDenied;
        case kABAuthorizationStatusRestricted:      return IIContactsAuthorizationStatusRestricted;
        case kABAuthorizationStatusNotDetermined:   return IIContactsAuthorizationStatusNotDetermined;
        default:                                    return IIContactsAuthorizationStatusNotDetermined;
    }
}

- (void)requestAuthorization {
    ABAddressBookRef addressBook = _addressBook;
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        dispatch_asyn_on_main(^{
            if (granted) {
                [NSNotificationCenter.defaultCenter postNotificationName:kContactsDidGrantedNotification object:nil userInfo:@{kContactsGrantedKey: @(IIContactsAuthorizationStatusAuthorized)}];
                [NSNotificationCenter.defaultCenter postNotificationName:kContactsDidUpdatedNotification object:nil userInfo:nil];
            } else {
                [NSNotificationCenter.defaultCenter postNotificationName:kContactsDidGrantedNotification object:nil userInfo:@{kContactsGrantedKey: @(IIContactsAuthorizationStatusDenied)}];
            }
        });
    });
}

- (NSArray<ZHContacter *> *)contacts {
    
    ABAddressBookRef addressBook = _addressBook;
    
    // 按照添加时间请求所有的联系人
    //CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(self.addressBook);
    
    // 按照排序规则请求所有的联系人
    ABRecordRef recordRef = ABAddressBookCopyDefaultSource(addressBook);
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, recordRef, kABPersonSortByFirstName);
    CFRelease(recordRef);
    
    NSMutableArray<ZHContacter *> *records = [NSMutableArray array];
    
    CFIndex count = CFArrayGetCount(people);
    
    for (CFIndex idx = 0; idx < count; idx++) {
        
        ABRecordRef recordRef = CFArrayGetValueAtIndex(people, idx);
        
        ZHContacter *contacter = [ZHContacter.alloc initWithRecord:recordRef];
        
        [records addObject:contacter];
    }
    
    CFRelease(people);
    
    return records;
}

@end
