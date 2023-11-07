//
//  Date+Extension.swift
//  HKCommon.swift
//  HookMemory
//
//  Created by HF on 2023/11/2.
//

import Foundation

extension Date {
    
    /// 获取当前 秒级 时间戳 - 10位
    var timeStamp: String {
        
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        
        let timeStamp = Int(timeInterval)
        
        return "\(timeStamp)"
    }
    
    /// 获取当前 毫秒级 时间戳 - 13位
    var milliStamp: String {
        
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        
        let millisecond = CLongLong(round(timeInterval * 1000))
        
        return "\(millisecond)"
    }
    
    /// 日期转化为日期字符串
    ///
    /// - Parameter format: 日期格式
    /// EEEE:表示星期几(Monday),使用1-3个字母表示周几的缩写
    /// MMMM:月份的全写(October),使用1-3个字母表示月份的缩写
    /// dd:表示日期,使用一个字母表示没有前导0
    /// YYYY:四个数字的年份(2016)
    /// HH:两个数字表示的小时(02或21)
    /// mm:两个数字的分钟 (02或54)
    /// ss:两个数字的秒
    /// zzz:三个字母表示的时区
    /// - Returns: 日期字符串
    func formatString(_ format: String = "MMM dd, yyyy") -> String {
        
        let formater: DateFormatter = DateFormatter()
        
        formater.dateFormat = format
        
        return formater.string(from: self)
    }
    
    func formatMonthString(_ format: String = "MMM") -> String {
        
        let formater: DateFormatter = DateFormatter()
        
        formater.dateFormat = format
        
        return formater.string(from: self)
    }
    
    func formatDayString(_ format: String = "dd") -> String {
        
        let formater: DateFormatter = DateFormatter()
        
        formater.dateFormat = format
        
        return formater.string(from: self)
    }
    /// 判断时间戳是否为今天
    ///
    /// - Parameter tp: 时间戳
    /// - Returns: Bool
    static func IsTodayTime(tp: String) -> Bool{
        let calendar = Calendar.current
        let unit: Set<Calendar.Component> = [.day,.month,.year]
        let nowComps = calendar.dateComponents(unit, from: Date())
        
        let timeSp = TimeInterval(tp)
        
        guard timeSp != nil else {
            
            return false
        }
        
        let date = Date.init(timeIntervalSince1970: timeSp!)
        
        let selfCmps = calendar.dateComponents(unit, from: date)
        
        return (selfCmps.year == nowComps.year) &&
        (selfCmps.month == nowComps.month) &&
        (selfCmps.day == nowComps.day)
        
    }
}
