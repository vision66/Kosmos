//
//  IIContact.swift
//  student
//
//  Created by weizhen on 2019/1/9.
//  Copyright © 2019 Wuhan Mengxin Technology Co., Ltd. All rights reserved.
//

import Foundation
import AddressBook
import Contacts


@available(iOS, introduced: 2.0, deprecated: 9.0, message: "CNEntityType")
enum IIEntityType : Int {
    
    case contacts
}


@available(iOS, introduced: 2.0, deprecated: 9.0, message: "CNAuthorizationStatus")
enum IIAuthorizationStatus : Int {
    
    case notDetermined
    
    case restricted
    
    case denied
    
    case authorized
}


@available(iOS, introduced: 2.0, deprecated: 9.0, message: "CNContactStore")
class IIContactStore : NSObject {
    
    private var addressBook: ABAddressBook!
    
    var externalChangeCallback : ABExternalChangeCallback = { addressBook, dict, context -> Void in
        NotificationCenter.default.post(name: NSNotification.Name.IIContactStoreDidChange, object: nil, userInfo: nil)
    }
    
    override init() {
        self.addressBook = ABAddressBookCreateWithOptions(nil, nil)?.takeRetainedValue()
        super.init()
        ABAddressBookRegisterExternalChangeCallback(addressBook, externalChangeCallback, nil)        
    }
    
    deinit {
        ABAddressBookUnregisterExternalChangeCallback(addressBook, externalChangeCallback, nil)
    }
    
    class func authorizationStatus(for entityType: IIEntityType) -> IIAuthorizationStatus {
        let status = ABAddressBookGetAuthorizationStatus()
        switch (status) {
        case .authorized:      return .authorized
        case .denied:          return .denied
        case .restricted:      return .restricted
        case .notDetermined:   return .notDetermined
        }
    }
    
    func requestAccess(for entityType: IIEntityType, completionHandler: @escaping (Bool, Error?) -> Void) {
        ABAddressBookRequestAccessWithCompletion(addressBook) { granted, error in
            completionHandler(granted, error)
        }
    }
    
    //func unifiedContacts(matching predicate: NSPredicate, keysToFetch keys: [IIKeyDescriptor]) throws -> [IIContact]
    
    //func unifiedContact(withIdentifier identifier: String, keysToFetch keys: [IIKeyDescriptor]) throws -> IIContact
    
    func enumerateContacts(with fetchRequest: IIContactFetchRequest, usingBlock block: @escaping (IIContact, UnsafeMutablePointer<ObjCBool>) -> Void) throws {
        
        let people : CFArray
        if fetchRequest.sortOrder == .none {
            people = ABAddressBookCopyArrayOfAllPeople(addressBook)!.takeRetainedValue()
        } else if fetchRequest.sortOrder == .userDefault {
            let source = ABAddressBookCopyDefaultSource(addressBook)!.takeRetainedValue()
            people = ABAddressBookCopyArrayOfAllPeopleInSource(addressBook, source)!.takeRetainedValue()
        } else {
            let source = ABAddressBookCopyDefaultSource(addressBook)!.takeRetainedValue()
            people = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, fetchRequest.sortOrder.rawValue)!.takeRetainedValue()
        }
        
        let count = CFArrayGetCount(people)
        
        for index in 0..<count {
            
            let record = unsafeBitCast(CFArrayGetValueAtIndex(people, index), to: ABRecord.self)
            
            let contact = IIContact(record: record, keysToFetch: fetchRequest.keysToFetch)
            
            var stop = ObjCBool(false)
            
            block(contact, &stop)
            
            if stop.boolValue {
                break
            }
        }
    }
    
    //func groups(matching predicate: NSPredicate?) throws -> [IIGroup]
    
    //func containers(matching predicate: NSPredicate?) throws -> [IIContainer]
    
    //func execute(_ saveRequest: IISaveRequest) throws
    
    //func defaultContainerIdentifier() -> String
}


extension NSNotification.Name {

    @available(iOS, introduced: 2.0, deprecated: 9.0, message: "CNContactStoreDidChange")
    static let IIContactStoreDidChange: NSNotification.Name = NSNotification.Name("IIContactStoreDidChange")
}


@available(iOS, introduced: 2.0, deprecated: 9.0, message: "CNContactType")
enum IIContactType : Int {
    
    case person
    
    case organization
}


@available(iOS, introduced: 2.0, deprecated: 9.0, message: "CNContactSortOrder")
enum IIContactSortOrder : UInt32 {
    
    case none = 100
    
    case userDefault = 200
    
    case givenName = 0
    
    case familyName = 1
}


@available(iOS, introduced: 2.0, deprecated: 9.0, message: "CNKeyDescriptor")
protocol IIKeyDescriptor : NSCopying, NSSecureCoding, NSObjectProtocol {
    
}


@available(iOS, introduced: 2.0, deprecated: 9.0, message: "Contacts")
extension NSString : IIKeyDescriptor {
    
}


@available(iOS, introduced: 2.0, deprecated: 9.0, message: "CNContact")
//class IIContact : NSObject, NSCopying, NSMutableCopying, NSSecureCoding {
class IIContact : NSObject {
    
    private var keysToFetch: [IIKeyDescriptor]
    
    init(record: ABRecord, keysToFetch: [IIKeyDescriptor]) {
        
        self.keysToFetch = keysToFetch
        super.init()
        
        if isKeyAvailable(IIContactNamePrefixKey) {
            self.namePrefix = fetchLabeledValue(record, IIContactNamePrefixKey)
        }
        
        if isKeyAvailable(IIContactNameSuffixKey) {
            self.nameSuffix = fetchLabeledValue(record, IIContactNameSuffixKey)
        }
        
        if isKeyAvailable(IIContactGivenNameKey) {
            self.givenName = fetchLabeledValue(record, IIContactGivenNameKey)
        }
        
        if isKeyAvailable(IIContactFamilyNameKey) {
            self.familyName = fetchLabeledValue(record, IIContactFamilyNameKey)
        }
        
        if isKeyAvailable(IIContactMiddleNameKey) {
            self.middleName = fetchLabeledValue(record, IIContactMiddleNameKey)
        }
        
        if isKeyAvailable(IIContactNicknameKey) {
            self.nickname = fetchLabeledValue(record, IIContactNicknameKey)
        }
        
        if isKeyAvailable(IIContactOrganizationNameKey) {
            self.organizationName = fetchLabeledValue(record, IIContactOrganizationNameKey)
        }
        
        if isKeyAvailable(IIContactDepartmentNameKey) {
            self.departmentName = fetchLabeledValue(record, IIContactDepartmentNameKey)
        }
        
        if isKeyAvailable(IIContactJobTitleKey) {
            self.jobTitle = fetchLabeledValue(record, IIContactJobTitleKey)
        }
        
        if isKeyAvailable(IIContactNoteKey) {
            self.jobTitle = fetchLabeledValue(record, IIContactNoteKey)
        }
        
        if isKeyAvailable(IIContactTypeKey) {
            self.contactType = fetchContactType(record)
        }
        
        if isKeyAvailable(IIContactEmailAddressesKey) {
            self.emailAddresses = fetchEmailAddresses(record)
        }
        
        if isKeyAvailable(IIContactPostalAddressesKey) {
            self.postalAddresses = fetchLabeledValues(record, IIContactPostalAddressesKey)
        }
        
        if isKeyAvailable(IIContactPhoneNumbersKey) {
            self.phoneNumbers = fetchLabeledValues(record, IIContactPhoneNumbersKey)
        }
    }
    
    //private(set) var identifier: String
    
    private(set) var contactType: IIContactType = .person
    
    private func fetchContactType(_ record: ABRecord) -> IIContactType {
        let number = ABRecordCopyValue(record, kABPersonKindProperty)!.takeRetainedValue() as! CFNumber
        let result = CFNumberCompare(number, kABPersonKindOrganization, nil)
        let contactType : IIContactType = (result == .compareEqualTo) ? .person : .organization
        return contactType
    }
    
    private(set) var namePrefix: String = ""
    
    private(set) var givenName: String = ""
    
    private(set) var middleName: String = ""
    
    private(set) var familyName: String = ""
    
    //private(set) var previousFamilyName: String = ""
    
    private(set) var nameSuffix: String = ""
    
    private(set) var nickname: String = ""
    
    private(set) var organizationName: String = ""
    
    private(set) var departmentName: String = ""
    
    private(set) var jobTitle: String = ""
    
    //private(set) var phoneticGivenName: String
    
    //private(set) var phoneticMiddleName: String
    
    //private(set) var phoneticFamilyName: String
    
    //private(set) var phoneticOrganizationName: String
    
    private(set) var note: String = ""
    
    //private(set) var imageData: Data?
    
    //private(set) var thumbnailImageData: Data?
    
    //private(set) var imageDataAvailable: Bool
    
    private(set) var phoneNumbers = [IILabeledValue<IIPhoneNumber>]()
    
    private(set) var emailAddresses = [IILabeledValue<NSString>]()
    
    private(set) var postalAddresses = [IILabeledValue<IIPostalAddress>]()
    
    private func fetchLabeledValue(_ record: ABRecord!, _ key: String) -> String {
        let property = IIContact.getPropertyID(forKey: key)
        return ABRecordCopyValue(record, property)!.takeRetainedValue() as! String
    }
    
    private class func getPropertyID(forKey key: String) -> ABPropertyID {
        switch key {
        case IIContactNamePrefixKey: return kABPersonPrefixProperty
        case IIContactGivenNameKey: return kABPersonFirstNameProperty
        case IIContactMiddleNameKey: return kABPersonMiddleNameProperty
        case IIContactFamilyNameKey: return kABPersonLastNameProperty
        case IIContactNameSuffixKey: return kABPersonSuffixProperty
        case IIContactNicknameKey: return kABPersonNicknameProperty
        case IIContactOrganizationNameKey: return kABPersonOrganizationProperty
        case IIContactDepartmentNameKey: return kABPersonDepartmentProperty
        case IIContactJobTitleKey: return kABPersonJobTitleProperty
        case IIContactPhoneticGivenNameKey: return kABPersonFirstNamePhoneticProperty
        case IIContactPhoneticMiddleNameKey: return kABPersonMiddleNamePhoneticProperty
        case IIContactPhoneticFamilyNameKey: return kABPersonLastNamePhoneticProperty
        case IIContactBirthdayKey: return kABPersonBirthdayProperty
        case IIContactNoteKey: return kABPersonNoteProperty
        case IIContactPhoneNumbersKey: return kABPersonPhoneProperty
        case IIContactEmailAddressesKey: return kABPersonEmailProperty
        case IIContactPostalAddressesKey: return kABPersonAddressProperty
        case IIContactDatesKey: return kABPersonDateProperty
        case IIContactUrlAddressesKey: return kABPersonURLProperty
        case IIContactRelationsKey: return kABPersonRelatedNamesProperty
        case IIContactSocialProfilesKey: return kABPersonSocialProfileProperty
        case IIContactInstantMessageAddressesKey: return kABPersonInstantMessageProperty
        default: fatalError("\(key) is still not implement")
        }
    }
    
    private func fetchEmailAddresses(_ record: ABRecord) -> [IILabeledValue<NSString>] {
        
        var labeledValues = [IILabeledValue<NSString>]()
        
        let values = ABRecordCopyValue(record, kABPersonEmailProperty)!.takeRetainedValue()
        
        let count = ABMultiValueGetCount(values)
        
        for i in 0 ..< count {
            
            let label = ABMultiValueCopyLabelAtIndex(values, i)!.takeRetainedValue()
            
            let value = ABMultiValueCopyValueAtIndex(values, i)!.takeRetainedValue()
            
            let labeledValue = IILabeledValue<NSString>(label: label as String, value: value as! NSString)
            
            labeledValues.append(labeledValue)
        }
        
        return labeledValues
    }
    
    private func fetchLabeledValues<ValueType>(_ record: ABRecord, _ key: String) -> [IILabeledValue<ValueType>] where ValueType : IIContactElement {
        
        let property = IIContact.getPropertyID(forKey: key)
        
        var labeledValues = [IILabeledValue<ValueType>]()
        
        let values = ABRecordCopyValue(record, property)!.takeRetainedValue()
        
        let count = ABMultiValueGetCount(values)
        
        for i in 0 ..< count {
            
            let label = ABMultiValueCopyLabelAtIndex(values, i)!.takeRetainedValue()
            
            let value = ABMultiValueCopyValueAtIndex(values, i)!.takeRetainedValue()
            
            let inst = ValueType(value: value)
            
            let labeledValue = IILabeledValue<ValueType>(label: label as String, value: inst)
            
            labeledValues.append(labeledValue)
        }
        
        return labeledValues
    }
    
    //private(set) var urlAddresses: [IILabeledValue<NSString>]
    
    //private(set) var contactRelations: [IILabeledValue<IIContactRelation>]
    
    //private(set) var socialProfiles: [IILabeledValue<IISocialProfile>]
    
    //private(set) var instantMessageAddresses: [IILabeledValue<IIInstantMessageAddress>]
    
    //private(set) var birthday: DateComponents?
    
    //private(set) var nonGregorianBirthday: DateComponents?
    
    //private(set) var dates: [IILabeledValue<NSDateComponents>]
    
    func isKeyAvailable(_ key: String) -> Bool {
        return keysToFetch.contains { descriptor -> Bool in
            if let des = descriptor as? NSString {
                return (des as String) == key
            }
            return false
        }
    }
    
    func areKeysAvailable(_ keyDescriptors: [IIKeyDescriptor]) -> Bool {
        for keyDescriptor in keyDescriptors {
            if let d = keyDescriptor as? NSString, isKeyAvailable(d as String) == false {
                return false
            }
        }
        return true
    }
    
    class func localizedString(forKey key: String) -> String {
        let property = getPropertyID(forKey: key)
        return ABPersonCopyLocalizedPropertyName(property)!.takeRetainedValue() as String
    }
    
    //class func comparator(forNameSortOrder sortOrder: IIContactSortOrder) -> Comparator
    
    //class func descriptorForAllComparatorKeys() -> IIKeyDescriptor
    
    //func isUnifiedWithContact(withIdentifier contactIdentifier: String) -> Bool
}


let IIContactPropertyNotFetchedExceptionName: String = "IIContactPropertyNotFetchedExceptionName"
let IIContactIdentifierKey: String = "IIContactIdentifierKey"
let IIContactNamePrefixKey: String = "IIContactNamePrefixKey"
let IIContactGivenNameKey: String = "IIContactGivenNameKey"
let IIContactMiddleNameKey: String = "IIContactMiddleNameKey"
let IIContactFamilyNameKey: String = "IIContactFamilyNameKey"
let IIContactPreviousFamilyNameKey: String = "IIContactPreviousFamilyNameKey"
let IIContactNameSuffixKey: String = "IIContactNameSuffixKey"
let IIContactNicknameKey: String = "IIContactNicknameKey"
let IIContactOrganizationNameKey: String = "IIContactOrganizationNameKey"
let IIContactDepartmentNameKey: String = "IIContactDepartmentNameKey"
let IIContactJobTitleKey: String = "IIContactJobTitleKey"
let IIContactPhoneticGivenNameKey: String = "IIContactPhoneticGivenNameKey"
let IIContactPhoneticMiddleNameKey: String = "IIContactPhoneticMiddleNameKey"
let IIContactPhoneticFamilyNameKey: String = "IIContactPhoneticFamilyNameKey"
let IIContactPhoneticOrganizationNameKey: String = "IIContactPhoneticOrganizationNameKey"
let IIContactBirthdayKey: String = "IIContactBirthdayKey"
let IIContactNonGregorianBirthdayKey: String = "IIContactNonGregorianBirthdayKey"
let IIContactNoteKey: String = "IIContactNoteKey"
let IIContactImageDataKey: String = "IIContactImageDataKey"
let IIContactThumbnailImageDataKey: String = "IIContactThumbnailImageDataKey"
let IIContactImageDataAvailableKey: String = "IIContactImageDataAvailableKey"
let IIContactTypeKey: String = "IIContactTypeKey"
let IIContactPhoneNumbersKey: String = "IIContactPhoneNumbersKey"
let IIContactEmailAddressesKey: String = "IIContactEmailAddressesKey"
let IIContactPostalAddressesKey: String = "IIContactPostalAddressesKey"
let IIContactDatesKey: String = "IIContactDatesKey"
let IIContactUrlAddressesKey: String = "IIContactUrlAddressesKey"
let IIContactRelationsKey: String = "IIContactRelationsKey"
let IIContactSocialProfilesKey: String = "IIContactSocialProfilesKey"
let IIContactInstantMessageAddressesKey: String = "IIContactInstantMessageAddressesKey"


@available(iOS, introduced: 2.0, deprecated: 9.0, message: "CNContactFetchRequest")
class IIContactFetchRequest : NSObject {
    
    init(keysToFetch: [IIKeyDescriptor]) {
        self.keysToFetch = keysToFetch
        super.init()
    }
    
    @NSCopying var predicate: NSPredicate?
    
    var keysToFetch: [IIKeyDescriptor]
    
    var mutableObjects: Bool = false
    
    var unifyResults: Bool = true
    
    var sortOrder: IIContactSortOrder = .none
}


@available(iOS, introduced: 2.0, deprecated: 9.0, message: "CNContactElement")
protocol IIContactElement {
    
    init(value: CFTypeRef?)
}


@available(iOS, introduced: 2.0, deprecated: 9.0, message: "CNLabeledValue")
//class IILabeledValue<ValueType> : NSObject, NSCopying, NSSecureCoding where ValueType : NSCopying, ValueType : NSSecureCoding {
class IILabeledValue<ValueType> : NSObject where ValueType : NSCopying, ValueType : NSSecureCoding {
    
    private(set) var label: String?
    
    @NSCopying private(set) var value: ValueType
    
    init(label: String?, value: ValueType) {
        self.label = label
        self.value = value
        super.init()
    }
    
    //func settingLabel(_ label: String?) -> Self
    
    //func settingValue(_ value: ValueType) -> Self
    
    //func settingLabel(_ label: String?, value: ValueType) -> Self
    
    class func localizedString(forLabel label: String) -> String {
        return ABAddressBookCopyLocalizedLabel(label as CFString)!.takeRetainedValue() as String
    }
}


let IILabelHome: String = "IILabelHome"
let IILabelWork: String = "IILabelWork"
let IILabelOther: String = "IILabelOther"
let IILabelEmailiCloud: String = "IILabelEmailiCloud"
let IILabelURLAddressHomePage: String = "IILabelURLAddressHomePage"
let IILabelDateAnniversary: String = "IILabelDateAnniversary"


@available(iOS, introduced: 2.0, deprecated: 9.0, message: "CNPhoneNumber")
class IIPhoneNumber : NSObject, IIContactElement, NSCopying, NSSecureCoding {
    
    required init(value: CFTypeRef?) {
        super.init()
        guard let value = value else { return }
        self.stringValue = value as! String
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let theCopyObj = type(of: self).init(value: nil)
        theCopyObj.stringValue = self.stringValue
        return theCopyObj
    }
    
    static var supportsSecureCoding: Bool { return true }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(stringValue, forKey: "stringValue")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.stringValue = aDecoder.decodeObject(forKey: "stringValue") as! String
    }
    
    init(stringValue string: String) {
        self.stringValue = string
        super.init()
    }
    
    //init!()
    
    //class func new() -> Self!
    
    var stringValue: String = ""
}


let IILabelPhoneNumberiPhone: String = "IILabelPhoneNumberiPhone"
let IILabelPhoneNumberMobile: String = "IILabelPhoneNumberMobile"
let IILabelPhoneNumberMain: String = "IILabelPhoneNumberMain"
let IILabelPhoneNumberHomeFax: String = "IILabelPhoneNumberHomeFax"
let IILabelPhoneNumberWorkFax: String = "IILabelPhoneNumberWorkFax"
let IILabelPhoneNumberOtherFax: String = "IILabelPhoneNumberOtherFax"
let IILabelPhoneNumberPager: String = "IILabelPhoneNumberPager"


@available(iOS, introduced: 2.0, deprecated: 9.0, message: "CNPostalAddress")
class IIPostalAddress : NSObject, IIContactElement, NSCopying, NSMutableCopying, NSSecureCoding {
    
    required init(value: CFTypeRef?) {
        super.init()
        guard let value = value else { return }
        let dict = value as! CFDictionary
        street = pickup(dict: dict, key: kABPersonAddressStreetKey)
        city = pickup(dict: dict, key: kABPersonAddressCityKey)
        state = pickup(dict: dict, key: kABPersonAddressStateKey)
        postalCode = pickup(dict: dict, key: kABPersonAddressZIPKey)
        country = pickup(dict: dict, key: kABPersonAddressCountryKey)
        isoCountryCode = pickup(dict: dict, key: kABPersonAddressCountryCodeKey)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let theCopyObj = type(of: self).init(value: nil)
        theCopyObj.street = self.street
        theCopyObj.subLocality = self.subLocality
        theCopyObj.city = self.city
        theCopyObj.subAdministrativeArea = self.subAdministrativeArea
        theCopyObj.state = self.state
        theCopyObj.postalCode = self.postalCode
        theCopyObj.country = self.country
        theCopyObj.isoCountryCode = self.isoCountryCode
        return theCopyObj
    }
    
    func mutableCopy(with zone: NSZone? = nil) -> Any {
        let theCopyObj = type(of: self).init(value: nil)
        theCopyObj.street = self.street
        theCopyObj.subLocality = self.subLocality
        theCopyObj.city = self.city
        theCopyObj.subAdministrativeArea = self.subAdministrativeArea
        theCopyObj.state = self.state
        theCopyObj.postalCode = self.postalCode
        theCopyObj.country = self.country
        theCopyObj.isoCountryCode = self.isoCountryCode
        return theCopyObj
    }
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(street, forKey: IIPostalAddressStreetKey)
        aCoder.encode(subLocality, forKey: IIPostalAddressSubLocalityKey)
        aCoder.encode(city, forKey: IIPostalAddressCityKey)
        aCoder.encode(subAdministrativeArea, forKey: IIPostalAddressSubAdministrativeAreaKey)
        aCoder.encode(state, forKey: IIPostalAddressStateKey)
        aCoder.encode(postalCode, forKey: IIPostalAddressPostalCodeKey)
        aCoder.encode(country, forKey: IIPostalAddressCountryKey)
        aCoder.encode(isoCountryCode, forKey: IIPostalAddressISOCountryCodeKey)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.street = aDecoder.decodeObject(forKey: IIPostalAddressStreetKey) as! String
        self.subLocality = aDecoder.decodeObject(forKey: IIPostalAddressSubLocalityKey) as! String
        self.city = aDecoder.decodeObject(forKey: IIPostalAddressCityKey) as! String
        self.subAdministrativeArea = aDecoder.decodeObject(forKey: IIPostalAddressSubAdministrativeAreaKey) as! String
        self.state = aDecoder.decodeObject(forKey: IIPostalAddressStateKey) as! String
        self.postalCode = aDecoder.decodeObject(forKey: IIPostalAddressPostalCodeKey) as! String
        self.country = aDecoder.decodeObject(forKey: IIPostalAddressCountryKey) as! String
        self.isoCountryCode = aDecoder.decodeObject(forKey: IIPostalAddressISOCountryCodeKey) as! String
    }
    
    @objc private(set) var street: String = ""
    
    @objc private(set) var subLocality: String = ""
    
    @objc private(set) var city: String = ""
    
    @objc private(set) var subAdministrativeArea: String = ""
    
    @objc private(set) var state: String = ""
    
    @objc private(set) var postalCode: String = ""
    
    @objc private(set) var country: String = ""
    
    @objc private(set) var isoCountryCode: String = ""
    
    class func localizedString(forKey key: String) -> String {
        switch key {
        case IIPostalAddressStreetKey: return "street"
        case IIPostalAddressSubLocalityKey: return "subLocality"
        case IIPostalAddressCityKey: return "city"
        case IIPostalAddressSubAdministrativeAreaKey: return "subAdministrativeArea"
        case IIPostalAddressStateKey: return "state"
        case IIPostalAddressPostalCodeKey: return "postalCode"
        case IIPostalAddressCountryKey: return "country"
        case IIPostalAddressISOCountryCodeKey: return "isoCountryCode"
        default: fatalError("\(key) is still not implement")
        }
    }
    
    private func pickup(dict: CFDictionary, key: CFString) -> String {
        let key = Unmanaged.passRetained(key).autorelease().toOpaque()
        let value = CFDictionaryGetValue(dict, key)
        return Unmanaged<CFString>.fromOpaque(value!).takeUnretainedValue() as String
    }
}


let IIPostalAddressStreetKey: String = "street"
let IIPostalAddressSubLocalityKey: String = "subLocality"
let IIPostalAddressCityKey: String = "city"
let IIPostalAddressSubAdministrativeAreaKey: String = "subAdministrativeArea"
let IIPostalAddressStateKey: String = "state"
let IIPostalAddressPostalCodeKey: String = "postalCode"
let IIPostalAddressCountryKey: String = "country"
let IIPostalAddressISOCountryCodeKey: String = "isoCountryCode"
