//
//  Date+Extension.swift
//  YoItems
//
//  Created by Yuki Ono on 2023/04/09.
//

import Foundation
extension Date {
    
    public var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .japan
        calendar.locale   = .japan
        return calendar
    }
}

extension Date {
    public init(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) {
        self.init(
            timeIntervalSince1970: Date().fixed(
                year:   year,
                month:  month,
                day:    day,
                hour:   hour,
                minute: minute,
                second: second
            ).timeIntervalSince1970
        )
    }
}
extension Date {
    public func fixed(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date {
        let calendar = self.calendar
        
        var comp = DateComponents()
        comp.year   = year   ?? calendar.component(.year,   from: self)
        comp.month  = month  ?? calendar.component(.month,  from: self)
        comp.day    = day    ?? calendar.component(.day,    from: self)
        comp.hour   = hour   ?? calendar.component(.hour,   from: self)
        comp.minute = minute ?? calendar.component(.minute, from: self)
        comp.second = second ?? calendar.component(.second, from: self)
        
        return calendar.date(from: comp)!
    }
    
    public func added(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date {
        let calendar = self.calendar
        
        var comp = DateComponents()
        comp.year   = (year   ?? 0) + calendar.component(.year,   from: self)
        comp.month  = (month  ?? 0) + calendar.component(.month,  from: self)
        comp.day    = (day    ?? 0) + calendar.component(.day,    from: self)
        comp.hour   = (hour   ?? 0) + calendar.component(.hour,   from: self)
        comp.minute = (minute ?? 0) + calendar.component(.minute, from: self)
        comp.second = (second ?? 0) + calendar.component(.second, from: self)
        
        return calendar.date(from: comp)!
    }
}
extension Date {
    public var year: Int {
        return calendar.component(.year, from: self)
    }
    
    public var month: Int {
        return calendar.component(.month, from: self)
    }
    
    public var day: Int {
        return calendar.component(.day, from: self)
    }
    
    public var hour: Int {
        return calendar.component(.hour, from: self)
    }
    
    public var minute: Int {
        return calendar.component(.minute, from: self)
    }
    
    public var second: Int {
        return calendar.component(.second, from: self)
    }
    
    public var weekName: String {
        let index = calendar.component(.weekday, from: self) - 1 // index値を 1〜7 から 0〜6 にしている
        return ["日", "月", "火", "水", "木", "金", "土"][index]
    }
}

extension Date {
    public enum SymbolType {
        case `default`
        case standalone
        case veryShort
        case short
        case shortStandalone
        case veryShortStandalone
        case custom(symbols: [String])
    }
    
    public var weekIndex: Int {
        return calendar.component(.weekday, from: self) - 1
    }
    
    public func weeks(_ type: SymbolType = .short, locale: Locale? = nil) -> [String] {
        let formatter = DateFormatter()
        formatter.locale = locale ?? calendar.locale
        
        switch type {
        case .`default`:           return formatter.weekdaySymbols
        case .standalone:          return formatter.standaloneWeekdaySymbols
        case .veryShort:           return formatter.veryShortWeekdaySymbols
        case .short:               return formatter.shortWeekdaySymbols
        case .shortStandalone:     return formatter.shortStandaloneWeekdaySymbols
        case .veryShortStandalone: return formatter.veryShortStandaloneWeekdaySymbols
        case let .custom(symbols): return symbols
        }
    }
    
    public func week(_ type: SymbolType = .short, locale: Locale? = nil) -> String {
        return weeks(type, locale: locale)[weekIndex]
    }
}

extension Date {
    public var monthIndex: Int {
        return calendar.component(.month, from: self) - 1
    }
    
    // SymbolType は 前項の「曜日の取得」で定義したもの
    public func monthSymbols(_ type: SymbolType = .short, locale: Locale? = nil) -> [String] {
        let formatter = DateFormatter()
        formatter.locale = locale ?? calendar.locale
        
        switch type {
        case .`default`:           return formatter.monthSymbols
        case .standalone:          return formatter.standaloneMonthSymbols
        case .veryShort:           return formatter.veryShortMonthSymbols
        case .short:               return formatter.shortMonthSymbols
        case .shortStandalone:     return formatter.shortStandaloneMonthSymbols
        case .veryShortStandalone: return formatter.veryShortStandaloneMonthSymbols
        case let .custom(symbols): return symbols
        }
    }
    
    public func monthSymbol(_ type: SymbolType = .short, locale: Locale? = nil) -> String {
        return monthSymbols(type, locale: locale)[monthIndex]
    }
}

extension Date {
    // ◯秒前
    public func secondBefore(_ second: Int) -> Date {
        let day = Calendar.current.date(byAdding: .second, value: -second, to: self)
        return day!
    }
    
    // ◯秒後
    public func secondAfter(_ second: Int) -> Date {
        let day = Calendar.current.date(byAdding: .second, value: second, to: self)
        return day!
    }
    
    // ◯分前
    public func minuteBefore(_ minute: Int) -> Date {
        let day = Calendar.current.date(byAdding: .minute, value: -minute, to: self)
        return day!
    }
    
    // ◯分後
    public func minuteAfter(_ minute: Int) -> Date {
        let day = Calendar.current.date(byAdding: .minute, value: minute, to: self)
        return day!
    }
    
    // ◯時間前
    public func hourBefore(_ hour: Int) -> Date {
        let day = Calendar.current.date(byAdding: .hour, value: -hour, to: self)
        return day!
    }
    
    // ◯時間後
    public func hourAfter(_ hour: Int) -> Date {
        let day = Calendar.current.date(byAdding: .hour, value: hour, to: self)
        return day!
    }
    
    // その日の0時00分
    public var startTime: Date {
        return Calendar.current.startOfDay(for: self)
    }
}

extension Date {
    public var yesterday: Date {
        let day = Calendar.current.date(byAdding: .day, value: -1, to: self)
        return day!
    }
    
    public var tomorrow: Date {
        let day = Calendar.current.date(byAdding: .day, value: 1, to: self)
        return day!
    }
    
    // 1週間前
    public var oneWeekBefore: Date {
        let day = Calendar.current.date(byAdding: .day, value: -7, to: self)
        return day!
    }
    
    // 1週間後
    public var oneWeekAfter: Date {
        let day = Calendar.current.date(byAdding: .day, value: 7, to: self)
        return day!
    }
    
    // 1ヶ月前
    public var oneMonthBefore: Date {
        let day = Calendar.current.date(byAdding: .month, value: -1, to: self)
        return day!
    }
    
    // 1ヶ月後
    public var oneMonthAfter: Date {
        let day = Calendar.current.date(byAdding: .month, value: 1, to: self)
        return day!
    }
    
    // 1年前
    public var oneYearBefore: Date {
        let day = Calendar.current.date(byAdding: .year, value: -1, to: self)
        return day!
    }
    
    // 1年後
    public var oneYearAfter: Date {
        let day = Calendar.current.date(byAdding: .year, value: 1, to: self)
        return day!
    }
    
    // 月初
    public var beginningOfTheMonth: Date {
        let component = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: component)!
    }
    
    // 月末
    public var endOfTheMonth: Date {
        let beginningOfTheMonth = self.beginningOfTheMonth
        let add = DateComponents(month: 1, day: -1)
        return Calendar.current.date(byAdding: add, to: beginningOfTheMonth)!
    }
    
    // 年始
    public var beginningOfTheYear: Date {
        let component = Calendar.current.dateComponents([.year], from: self)
        return Calendar.current.date(from: component)!
    }
    
    // 年末
    public var endOfTheYear: Date {
        let beginningOfTheYear = self.beginningOfTheYear
        let add = DateComponents(year: 1, day: -1)
        return Calendar.current.date(byAdding: add, to: beginningOfTheYear)!
    }
}

extension Date {
    public var yyyyMMddHHmmss: String {
        return DateFormatter.yyyyMMddHHmmss.string(from: self)
    }
    
    public var yyyyMMddHHmm: String {
        return DateFormatter.yyyyMMddHHmm.string(from: self)
    }
    
    public var yyyyMMdd: String {
        return DateFormatter.yyyyMMdd.string(from: self)
    }
    
    public var MMdd: String {
        return DateFormatter.MMdd.string(from: self)
    }
    
    public var HHmm: String {
        return DateFormatter.HHmm.string(from: self)
    }
    
    public var kanjiyyyyMMddHHmmss: String {
        return DateFormatter.kanjiyyyyMMddHHmmss.string(from: self)
    }
    
    public var kanjiyyyyMMddHHmm: String {
        return DateFormatter.kanjiyyyyMMddHHmm.string(from: self)
    }
    
    public var kanjiyyyyMMdd: String {
        return DateFormatter.kanjiyyyyMMdd.string(from: self)
    }
    
    public var kanjiMMdd: String {
        return DateFormatter.kanjiMMdd.string(from: self)
    }
    
    public var kanjiHHmm: String {
        return DateFormatter.kanjiHHmm.string(from: self)
    }
    
    public var kanjiyyyyMMddE: String {
        return DateFormatter.kanjiyyyyMMddE.string(from: self)
    }
}
