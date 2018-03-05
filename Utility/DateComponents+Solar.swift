//
//  DateCompentSolar.swift
//  calender
//
//  Created by weizhen on 2017/11/13.
//  Copyright © 2017年 weizhen. All rights reserved.
//

import Foundation

extension DateComponents {

    var solarWeatherFestivalIndex : Int {
        
        // 计算阳历中的二十四节气在哪一天(2000~2099). Cs是二十四节气的修正值. 其中`大寒`等, 会计算到阳历的第二年
        let Cs = [3.87, 18.73, 5.63, 20.646, 4.81, 20.1, 5.52, 21.04, 5.678, 21.37, 7.108, 22.83, 7.5, 23.13, 7.646, 23.042, 8.318, 23.438, 7.438, 22.36, 7.18, 21.94, 5.4055, 20.12] // 共24个
        //  立春  2月3-4日        雨水  2月18-19日
        //  惊蛰  3月5-6日        春分  3月20-21日
        //  清明  4月4-6日        谷雨  4月19-20日
        //  立夏  5月5-6日        小满  5月20-22日
        //  芒种  6月5-6日        夏至  6月21-22日
        //  小暑  7月7-8日        大暑  7月22-23日
        //  立秋  8月6-9日        处暑  8月22-24日
        //  白露  9月7-8日        秋分  9月22-24日
        //  寒露 10月7-9日        霜降 10月23-24日
        //  立冬 11月7-8日        小雪 11月22-23日
        //  大雪 12月7-8日        冬至 12月21-23日
        //  小寒  1月5-6日        大寒  1月19-21日
        
        let i = (self.month! + 10) % 12 * 2 + ((self.day! < 15) ? 0 : 1)
        let Y = self.year! % 2000
        let D = 0.2422
        let C = Cs[i]
        let temp = Y - 1 // `temp` for Swift Error
        var day = Int(floor(Y * D + C) - floor(temp / 4))
        
        if (self.year == 2026 && i ==  1) {day = day - 1} // 例外: 2026年的计算结果减1日为18日
        if (self.year == 2084 && i ==  3) {day = day + 1} // 例外: 2084年的计算结果加1日
        if (self.year == 1911 && i ==  6) {day = day + 1} // 例外: 1911年的计算结果加1日
        if (self.year == 2008 && i ==  7) {day = day + 1} // 例外: 2008年的计算结果加1日
        if (self.year == 1902 && i ==  8) {day = day + 1} // 例外: 1902年的计算结果加1日
        if (self.year == 1928 && i ==  9) {day = day + 1} // 例外: 1928年的计算结果加1日
        if (self.year == 1925 && i == 10) {day = day + 1} // 例外: 1925年和2016年的计算结果加1日
        if (self.year == 2016 && i == 10) {day = day + 1} // 例外: 1925年和2016年的计算结果加1日
        if (self.year == 1922 && i == 11) {day = day + 1} // 例外: 1922年的计算结果加1日
        if (self.year == 2002 && i == 12) {day = day + 1} // 例外: 2002年的计算结果加1日
        if (self.year == 1927 && i == 14) {day = day + 1} // 例外: 1927年的计算结果加1日
        if (self.year == 1942 && i == 15) {day = day + 1} // 例外: 1942年的计算结果加1日
        if (self.year == 2089 && i == 17) {day = day + 1} // 例外: 2089年的计算结果加1日
        if (self.year == 2089 && i == 18) {day = day + 1} // 例外: 2089年的计算结果加1日
        if (self.year == 1978 && i == 19) {day = day + 1} // 例外: 1978年的计算结果加1日
        if (self.year == 1954 && i == 10) {day = day + 1} // 例外: 1954年的计算结果加1日
        if (self.year == 1918 && i == 21) {day = day - 1} // 例外: 1918年和2021年的计算结果减1日
        if (self.year == 2021 && i == 21) {day = day - 1} // 例外: 1918年和2021年的计算结果减1日
        if (self.year == 1982 && i == 22) {day = day + 1} // 例外: 1982年计算结果加1日，2019年减1日
        if (self.year == 2019 && i == 22) {day = day - 1} // 例外: 1982年计算结果加1日，2019年减1日
        
        return (self.day == day) ? i : -1
    }
    
    var solarWeatherFestival : String {
        let index = self.solarWeatherFestivalIndex
        guard index > 0 else { return "" }
        let solarWeatherFestival = ["立春", "雨水", "惊蛰", "春分", "清明", "谷雨", "立夏", "小满", "芒种", "夏至", "小暑", "大暑", "立秋", "处暑", "白露", "秋分", "寒露", "霜降", "立冬", "小雪", "大雪", "冬至", "小寒", "大寒"]
        return solarWeatherFestival[index]
    }
    
    var solarConstellation : String {
        
        let month = self.month
        let day = self.day!
        
        // 水瓶座 1月20日-------2月18日
        if (month ==  1 && day >= 20 && day <= 31) || (month ==  2 && day >= 1 && day <= 18) { return "水瓶座" }
        
        // 双鱼座 2月19日-------3月20日
        if (month ==  2 && day >= 19 && day <= 31) || (month ==  3 && day >= 1 && day <= 20) { return "双鱼座" }
        
        // 白羊座 3月21日-------4月19日
        if (month ==  3 && day >= 21 && day <= 31) || (month ==  4 && day >= 1 && day <= 19) { return "白羊座" }
        
        // 金牛座 4月20日-------5月20日
        if (month ==  4 && day >= 20 && day <= 31) || (month ==  5 && day >= 1 && day <= 20) { return "金牛座" }
        
        // 双子座 5月21日-------6月21日
        if (month ==  5 && day >= 21 && day <= 31) || (month ==  6 && day >= 1 && day <= 21) { return "双子座" }
        
        // 巨蟹座 6月22日-------7月22日
        if (month ==  6 && day >= 22 && day <= 31) || (month ==  7 && day >= 1 && day <= 22) { return "巨蟹座" }
        
        // 狮子座 7月23日-------8月22日
        if (month ==  7 && day >= 23 && day <= 31) || (month ==  8 && day >= 1 && day <= 22) { return "狮子座" }
        
        // 处女座 8月23日-------9月22日
        if (month ==  8 && day >= 23 && day <= 31) || (month ==  9 && day >= 1 && day <= 22) { return "处女座" }
        
        // 天秤座 9月23日------10月23日
        if (month ==  9 && day >= 23 && day <= 31) || (month == 10 && day >= 1 && day <= 23) { return "天秤座" }
        
        // 天蝎座 10月24日-----11月21日
        if (month == 10 && day >= 24 && day <= 31) || (month == 11 && day >= 1 && day <= 21) { return "天蝎座" }
        
        // 射手座 11月22日-----12月21日
        if (month == 11 && day >= 22 && day <= 31) || (month == 12 && day >= 1 && day <= 21) { return "射手座" }
        
        // 摩羯座 12月22日------1月19日
        if (month == 12 && day >= 22 && day <= 31) || (month ==  1 && day >= 1 && day <= 19) { return "摩羯座" }
        
        return ""
    }
    
    var solarFestivals : [String] {
        
        var festivals = [String]()
        
        let month = self.month
        let day = self.day
        
        // 1月1日：元旦节，阳历新年。
        if (month == 1 && day == 1) {
            festivals.append("元旦")
        }
        
        // 1月第一个星期日：黑人日
        // 1月8日：周恩来逝世纪念日
        // 1月10日，中国公安110宣传日。
        // 1月第二个星期一：日本成人节
        // 1月21日：列宁逝世纪念日
        // 1月26日：国际海关日
        // 1月最后一个星期日：世界防治麻风病日（国际麻风节）
        
        // 2月2日：世界湿地日
        if (month == 2 && day == 2) {
            festivals.append("湿地日")
        }
        
        // 2月4日：世界抗癌日
        // 2月7日：京汉铁路罢工纪念（1923）
        // 2月7日：国际声援南非日
        // 2月10日：国际气象节（1991）
        if (month == 2 && day == 10) {
            festivals.append("气象节")
        }
        
        // 2月14日：情人节
        if (month == 2 && day == 14) {
            festivals.append("情人节")
        }
        
        // 2月19日：邓小平逝世纪念日（1997）
        // 2月21日：反对殖民制度斗争日（1949）
        // 2月21日：国际母语日（2000）
        // 2月24日：第三世界青年日
        // 2月的最后一天：国际罕见病日
        // 2月的最后一天：世界居住条件调查日（2003）
        
        // 3月1日：国际海豹日（1983）
        // 3月3日：全国爱耳日（2000）
        if (month == 3 && day == 3) {
            festivals.append("爱耳日")
        }
        
        // 3月3日：世界野生动植物日（2013）
        // 3月5日：周恩来诞辰纪念日（1898）
        // 3月5日：“向雷锋同志学习”纪念日（1963）
        // 3月5日：中国青年志愿者服务日（2000）
        // 3月6日：世界青光眼日
        // 3月8日：国际劳动妇女节（1910）
        if (month == 3 && day == 8) {
            festivals.append("妇女节")
        }
        
        // 3月12日：孙中山逝世纪念日（1925）
        // 3月12日：中国植树节（1979）
        if (month == 3 && day == 12) {
            festivals.append("植树节")
        }
        
        // 3月14日：马克思逝世纪念日（1883）
        // 3月14日：白色情人节[1]
        // 3月15日：国际消费者权益日（1983）
        if (month == 3 && day == 15) {
            festivals.append("消费者权益日")
        }
        
        // 3月16日：手拉手情系贫困小伙伴全国统一行动日
        // 3月17日：国际航海日
        // 3月17日：中国国医节（1929）
        // 3月18日：全国科技人才活动日
        // 3月21日：世界林业节（世界森林日）（1972）
        // 3月21日：消除种族歧视国际日（1966）
        // 3月21日：世界儿歌日世界诗歌日（1976）
        // 3月21日：世界睡眠日（2001）
        // 3月22日至4月25日之间：复活节
        // 3月22日：世界水日（1993）
        // 3月23日：世界气象日（1960）
        if (month == 3 && day == 23) {
            festivals.append("气象日")
        }
        
        // 3月24日：世界防治结核病日（1996）
        // 3月30日：巴勒斯坦国土日（1962）
        // 3月最后一个星期一：全国中小学安全宣传教育日（1996）
        
        // 4月1日：国际愚人节
        if (month == 4 && day == 1) {
            festivals.append("愚人节")
        }
        
        // 4月2日：国际儿童图书日
        // 4月2日：世界自闭症日
        // 4月5日：清明节
        // 4月5日：巴勒斯坦儿童日
        // 4月7日：世界卫生日（1950）
        // 4月7日：世界高血压日
        // 4月10日：非洲环境保护日
        // 4月11日：世界帕金森日[2]（1997）
        // 4月15日：非洲自由日
        // 4月16日至18日：全球青年服务日
        // 4月17日：世界血友病日
        // 4月18日：国际古迹遗址日
        // 4月21日：全国企业家活动日（1994）
        // 4月22日：列宁诞辰纪念日（1870）
        // 4月22日：世界地球日（1970）
        if (month == 4 && day == 22) {
            festivals.append("地球日")
        }
        
        // 4月22日：世界法律日
        // 4月23日：世界图书和版权日（1995）
        // 4月24日：世界青年反对殖民主义日（1957）
        // 4月24日：亚非新闻工作者日
        // 4月25日：全国儿童预防接种宣传日（1986）
        // 4月26日：世界知识产权日（2001）
        // 4月27日：联谊城日
        // 4月28日：世界安全生产与健康日
        // 4月30日：全国交通安全反思日
        // 4月第四个星期日：世界儿童日（1986）
        // 4月最后一个完整星期中的星期三：秘书节
        
        // 5月1日：国际劳动节（1889）
        if (month == 5 && day == 1) {
            festivals.append("劳动节")
        }
        
        // 5月3日：世界新闻自由日
        // 5月4日：中国青年节（1939）
        if (month == 5 && day == 4) {
            festivals.append("青年节")
        }
        
        // 5月4日：五四运动纪念日（1919）
        // 5月5日：马克思诞辰纪念日（1818）
        // 5月8日：世界红十字日（1948）
        // 5月8日：世界微笑日
        // 5月第一周的星期二：世界哮喘日（1998）
        // 5月第二个星期六：世界高血压日（2005）[3]
        // 5月第二个星期日：母亲节（1914）
        if (month == 5) {
            let tags : Set<Calendar.Component> = [.weekday, .weekdayOrdinal]
            let components = self.calendar!.dateComponents(tags, from: self.date!)
            if (components.weekday == 1 && components.weekdayOrdinal == 2) {
                festivals.append("母亲节")
            }
        }
        
        // 5月11日：世界肥胖日
        // 5月12日：国际护士节（1912）
        if (month == 5 && day == 12) {
            festivals.append("护士节")
        }
        
        // 5月15日：全国碘缺乏病防治日（1994）
        // 5月15日：国际家庭日（国际咨询日）（1994）
        if (month == 5 && day == 15) {
            festivals.append("家庭日")
        }
        
        // 5月17日：世界电信日（1969）
        // 5月18日：国际博物馆日（1977）
        
        // 5月19日: 中国旅游日
        if (month == 5 && day == 19) {
            festivals.append("旅游日")
        }
        
        // 5月20日：全国母乳喂养宣传日（1990）
        // 5月20日：中国学生营养日（1990）
        // 5月20日：世界计量日（1999）
        // 5月22日：生物多样性国际日（2000）
        // 5月第三个星期日：全国助残日（1990）
        // 5月25日：非洲解放日（1963）
        // 5月26日：世界向人体条件挑战日（1993）
        // 5月27日：上海解放日（1949）
        // 5月29日：国际维和人员日（2002）
        // 5月30日：“五卅”反对帝国主义运动纪念日（1925）
        // 5月31日：世界无烟日（1988）
        if (month == 5 && day == 31) {
            festivals.append("无烟日")
        }
        
        // 6月1日：国际儿童节（1949）
        if (month == 6 && day == 1) {
            festivals.append("儿童节")
        }
        
        // 6月1日：国际牛奶日（1961）
        // 6月4日：受侵略戕害的无辜儿童国际日（1983）
        // 6月5日：世界环境日（1974）
        // 6月6日：全国爱眼日（1996）
        if (month == 6 && day == 6) {
            festivals.append("爱眼日")
        }
        
        // 6月8日：世界海洋日（2009）
        // 6月11日：中国人口日（1974）
        // 6月12日：世界无童工日（2002）
        // 6月14日：世界献血日（2004）
        // 6月17日：世界防止荒漠化和干旱日（1995）
        // 6月20日：世界难民日（2001）
        // 6月第三个星期日：父亲节（1934）
        if (month == 6) {
            let tags : Set<Calendar.Component> = [.weekday, .weekdayOrdinal]
            let components = self.calendar!.dateComponents(tags, from: self.date!)
            if (components.weekday == 1 && components.weekdayOrdinal == 3) {
                festivals.append("父亲节")
            }
        }
        
        // 6月22日：中国儿童慈善活动日
        // 6月23日：国际奥林匹克日（1948）
        if (month == 6 && day == 23) {
            festivals.append("奥林匹克日")
        }
        
        // 6月23日：世界手球日
        // 6月25日：全国土地日（1991）
        // 6月26日：国际禁毒日（国际反毒品日）（1987）
        if (month == 6 && day == 26) {
            festivals.append("禁毒日")
        }
        
        // 6月26日：禁止药物滥用和非法贩运国际日（1987）
        // 6月26日：国际宪章日（联合国宪章日）（1945）
        // 6月26日：支援酷刑受害者国际日（1997）
        
        // 7月1日：中国共产党诞生日（1921）
        if (month == 7 && day == 1) {
            festivals.append("建党节")
        }
        
        // 7月1日：香港回归纪念日（1997）
        if (month == 7 && day == 1) {
            festivals.append("香港回归")
        }
        
        // 7月1日：亚洲30亿人口日（1988）
        // 7月2日：国际体育记者日
        // 7月第一个星期六：国际合作节（国际合作社日）（1995）
        // 7月8日：世界过敏性疾病日
        // 7月7日：中国人民抗日战争纪念日（1937）
        if (month == 7 && day == 7) {
            festivals.append("七七事变")
        }
        
        // 7月11日：世界人口日（1987）
        if (month == 7 && day == 11) {
            festivals.append("人口日")
        }
        
        // 7月11日：中国航海节
        if (month == 7 && day == 11) {
            festivals.append("航海节")
        }
        
        // 7月26日：世界语创立日（1887）
        // 7月30日：非洲妇女日（1962）
        
        // 8月1日：中国人民解放军建军节（1927）
        if (month == 8 && day == 1) {
            festivals.append("建军节")
        }
        
        // 8月5日：恩格斯逝世纪念日（1895）
        // 8月6日：国际电影节（1932）
        // 8月8日：全民健身日（1988）
        // 8月12日：国际青年日（1999）
        // 8月13日：国际左撇子日（1976）
        // 8月15日：日本正式宣布无条件投降日（1945）
        if (month == 8 && day == 15) {
            festivals.append("日本投降日")
        }
        
        // 8月22日：邓小平诞辰纪念日（1904）
        // 8月23日：贩卖黑奴及其废除的国际纪念日
        // 8月26日：全国律师咨询日（1993）
        if (month == 8 && day == 26) {
            festivals.append("律师咨询日")
        }
        
        // 8月29日：禁止核试验国际日
        if (month == 8 && day == 29) {
            festivals.append("禁止核试验")
        }
        
        // 9月1日：全国中小学开学日
        // 9月3日：中国抗日战争胜利纪念日（1945）
        if (month == 9 && day == 3) {
            festivals.append("抗战胜利")
        }
        
        // 9月8日：国际新闻工作者日（1958）
        // 9月8日：世界扫盲日（1966）
        // 9月9日：毛泽东逝世纪念日（1976）
        // 9月10日：中国教师节（1985）
        if (month == 9 && day == 10) {
            festivals.append("教师节")
        }
        
        // 9月10日：世界预防自杀日
        // 9月14日：世界清洁地球日
        // 9月16日：国际臭氧层保护日（1994）
        // 9月18日：“九·一八”事变纪念日（中国国耻日）（1931）
        // 9月20日：全国爱牙日（1989）
        if (month == 9 && day == 20) {
            festivals.append("爱牙日")
        }
        
        // 9月21日：国际和平日（1981）
        // 9月22日：世界无车日（1998）
        // 9月第三个星期六：全民国防教育日（2001）
        // 9月21日：世界老年性痴呆宣传日
        // 9月27日：世界旅游日（1980）
        // 9月第四个星期日：国际聋人节（1958）
        // 9月最后一个星期日：世界心脏日（2000）
        // 9月最后一个星期日：世界海事日
        // 9月30日：中国烈士纪念日
        if (month == 9 && day == 30) {
            festivals.append("烈士纪念日")
        }
        
        // 10月1日：国庆节（1949）
        if (month == 10 && day == 1) {
            festivals.append("国庆节")
        }
        
        // 10月1日：国际音乐日（1980）
        // 10月1日：国际老年人日（国际老人节）（1990）
        // 10月2日：国际和平与民主自由斗争日（1949）
        // 10月4日：世界动物日
        // 10月5日：世界教师日（1944）
        // 10月第一个星期一：国际住房日（世界人居日）（1986）
        // 10月第一个星期一：国际建筑日（1985）
        // 10月第二个星期四：世界视觉日
        // 10月8日：全国高血压日（1998）
        // 10月9日：世界邮政日（万国邮联日）（1969）
        // 10月10日：辛亥革命纪念日（1911）
        if (month == 10 && day == 10) {
            festivals.append("辛亥革命")
        }
        
        // 10月10日：世界精神卫生日（世界心理健康日）（1992）
        // 10月第二个星期三：减少自然灾害国际日（1990）
        // 10月11日：声援南非政治犯日
        // 10月11日：世界镇痛日（2004）
        // 10月12日：世界60亿人口日（1999）
        // 10月13日：中国少年先锋队诞辰日（1949）
        // 10月13日：世界保健日（1950）
        // 10月14日：世界标准日（1969）
        // 10月15日：国际盲人节（白手杖节）
        // 10月16日：世界粮食日
        if (month == 10 && day == 16) {
            festivals.append("粮食日")
        }
        
        // 10月17日：世界消除贫困日（消灭贫穷国际日）
        // 10月22日：世界传统医药日
        // 10月24日：联合国日
        // 10月24日：世界发展宣传日（世界发展信息日）
        // 10月25日：抗美援朝纪念日（1950）
        // 10月28日：关注男性生殖健康日
        // 10月31日：世界勤俭日
        // 10月31日：万圣节前夕
        if (month == 10 && day == 31) {
            festivals.append("万圣节前夕")
        }
        
        // 植树造林日
        // 11月6日：防止战争和武装冲突糟蹋环境国际日（2001）
        // 11月7日：苏联十月革命纪念日（1917）
        // 11月7日：世界美发日（WorldHairdressingDay）
        // 11月7日：世界美容日（WorldBeautyDay）
        // 11月8日：中国记者节
        if (month == 11 && day == 8) {
            festivals.append("记者节")
        }
        
        // 11月9日：中国消防宣传日（消防节）
        // 11月10日：世界青年节（日）
        // 11月12日：刘少奇逝世纪念日（1969）
        // 11月12日：孙中山诞辰纪念日（1866）
        // 11月14日：世界糖尿病日（1995）
        // 11月16日：国际容忍日（国际宽容日）
        // 11月17日：国际大学生节（国际学生日）
        if (month == 11 && day == 17) {
            festivals.append("大学生节")
        }
        
        // 11月20日：非洲工业化日（1989）
        // 11月20日：国际儿童日
        // 11月21日：世界电视日
        // 11月21日：世界问候日（1973）
        // 11月24日：刘少奇诞辰纪念日（1898）
        // 11月25日：消除对妇女的暴力行为国际日（1999）
        // 11月25日：国际素食日（节）（1986）
        // 11月28日：恩格斯诞辰纪念日（1820）
        // 11月29日：声援巴勒斯坦人民国际日（1977）
        // 11月第四个星期四：美国感恩节
        if (month == 11) {
            let tags : Set<Calendar.Component> = [.weekday, .weekdayOrdinal]
            let components = self.calendar!.dateComponents(tags, from: self.date!)
            if (components.weekday == 5 && components.weekdayOrdinal == 4) {
                festivals.append("感恩节")
            }
        }
        
        // 12月1日：世界艾滋病日（1988）
        if (month == 12 && day == 1) {
            festivals.append("艾滋病日")
        }
        
        // 12月2日：废除奴隶制国际日（废除一切形式奴役世界日）（1986）
        // 12月3日：国际残疾人日（1992）
        // 12月4日：全国法制宣传日（2001）
        // 12月5日：促进经济和社会发展自愿人员国际日（1986）
        // 12月5日：世界弱能人士日（1990）
        // 12月7日：国际民航日（1994）
        // 12月9日：“一二·九”运动纪念日（1935）
        // 12月9日：世界足球日（1978）
        // 12月9日：国际反腐败日（2004）
        // 12月10日：世界人权日（1950）
        if (month == 12 && day == 10) {
            festivals.append("人权日")
        }
        
        // 12月11日：国际山岳日（2003）
        // 12月第二个星期日：国际儿童电视广播日（1997）
        // 12月12日：西安事变纪念日（1936）
        // 12月13日：南京大屠杀纪念日（1937）
        if (month == 12 && day == 13) {
            festivals.append("南京大屠杀")
        }
        
        // 12月15日：世界强化免疫日
        // 12月18日：国际移徙者日（2000）
        // 12月19日：联合国南南合作日（2004）
        // 12月20日：澳门回归纪念日（1999）
        if (month == 12 && day == 20) {
            festivals.append("澳门回归")
        }
        
        // 12月20日：国际人类团结日（2005）
        // 12月21日：国际篮球日（1891）
        // 12月24日：平安夜
        if (month == 12 && day == 24) {
            festivals.append("平安夜")
        }
        
        // 12月25日：圣诞节
        if (month == 12 && day == 25) {
            festivals.append("圣诞节")
        }
        
        // 12月26日：毛泽东诞辰纪念日（1893）
        // 12月26日：节礼日
        
        return festivals
    }

}
