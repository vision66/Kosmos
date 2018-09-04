//
//  lunar.swift
//  calender
//
//  Created by weizhen on 2017/11/13.
//  Copyright © 2017年 Wuhan Mengxin Technology Co., Ltd. All rights reserved.
//

import Foundation

extension DateComponents {
    
    var lunarYear : String {
        let lunarYear = ["甲子", "乙丑", "丙寅", "丁卯", "戊辰", "己巳", "庚午", "辛未", "壬申", "癸酉",
                         "甲戌", "乙亥", "丙子", "丁丑", "戊寅", "己卯", "庚辰", "辛己", "壬午", "癸未",
                         "甲申", "乙酉", "丙戌", "丁亥", "戊子", "己丑", "庚寅", "辛卯", "壬辰", "癸巳",
                         "甲午", "乙未", "丙申", "丁酉", "戊戌", "己亥", "庚子", "辛丑", "壬寅", "癸丑",
                         "甲辰", "乙巳", "丙午", "丁未", "戊申", "己酉", "庚戌", "辛亥", "壬子", "癸丑",
                         "甲寅", "乙卯", "丙辰", "丁巳", "戊午", "己未", "庚申", "辛酉", "壬戌", "癸亥"]
        return lunarYear[self.year! - 1]
    }
    
    var lunarMonth : String {
        let lunarMonth = ["正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "腊月"]
        return lunarMonth[self.month! - 1]
    }
    
    var lunarDay : String {
        let lunarDay = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
                        "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
                        "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
        return lunarDay[self.day! - 1]
    }
    
    var lunarZodiacIndex : Int {
        return (self.year! - 1) % 12
    }
    
    var lunarZodiac : String {
        let lunarZodiacs = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]
        return lunarZodiacs[self.lunarZodiacIndex]
    }
    
    var lunarFestivals : [String] {
        
        var festivals = [String]()
        
        let month = self.month
        let day = self.day
        
        // 元日: 正月初一，一年开始
        if month == 1 && day == 1 {
            festivals.append("春节")
        }
        
        // 上元: 正月十五，张灯为戏，又叫“灯节”
        if month == 1 && day == 15 {
            festivals.append("元宵")
        }
        
        // 端午: 五月初五，吃粽子，划龙（屈原）
        if month == 5 && day == 5 {
            festivals.append("端午")
        }
        
        // 七夕: 七月初七，妇女乞巧（牛郎织女）
        if month == 7 && day == 7 {
            festivals.append("七夕")
        }
        
        // 中元: 七月十五，祭祀鬼神，又叫“鬼节”
        if month == 7 && day == 15 {
            festivals.append("中元")
        }
        
        // 中秋: 八月十五，赏月，思乡
        if month == 8 && day == 15 {
            festivals.append("中秋")
        }
        
        // 重阳: 九月初九，登高，插茱萸免灾
        if month == 9 && day == 9 {
            festivals.append("重阳")
        }
        
        // 腊日: 腊月初八，喝“腊八粥”
        if month == 12 && day == 8 {
            festivals.append("腊八")
        }
        
        // 除夕: 一年的最后一天的晚上，初旧迎新
        let tomorrow = self.date!.addingTimeInterval(60*60*24)
        let tags : Set<Calendar.Component> = [.day, .month]
        let components = self.calendar!.dateComponents(tags, from: tomorrow)
        if components.month == 1 && components.day == 1 {
            festivals.append("除夕")
        }
        
        return festivals
    }
}
