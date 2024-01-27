//
//  DateFormatter+Extension.swift
//  YoItems
//
//  Created by Yuki Ono on 2023/04/09.
//

import Foundation
extension DateFormatter {
    public static var yyyyMMddHHmmss: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }
    
    public static var yyyyMMddHHmm: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }
    
    public static var yyyyMMdd: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }
    
    public static var MMdd: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }
    
    public static var HHmm: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }
    
    // MARK: kanji
    public static var kanjiyyyyMMddHHmmss: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日 HH時mm分ss秒"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }
    
    public static var kanjiyyyyMMddHHmm: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日 HH時mm分"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }
    
    public static var kanjiyyyyMMdd: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }
    
    public static var kanjiMMdd: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM年dd月"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }
    
    public static var kanjiHHmm: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH時mm分"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter
    }
    
    // MARK: kanji with week
    public static var kanjiyyyyMMddE: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日(E)"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "ja_JP")
        return dateFormatter
    }
}
