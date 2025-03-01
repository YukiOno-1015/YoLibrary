import Foundation

// MARK: - Date 拡張

public extension Date {
    /// **共通のカレンダー設定（グレゴリオ暦・日本時間）**
    private static var sharedCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .japan
        calendar.locale = .japan
        return calendar
    }

    /// **指定した年月日時分秒で Date を作成**
    init(year: Int? = nil, month: Int? = nil, day: Int? = nil,
         hour: Int? = nil, minute: Int? = nil, second: Int? = nil)
    {
        self = Date().fixed(year: year, month: month, day: day,
                            hour: hour, minute: minute, second: second)
    }

    /// **日付を固定**
    func fixed(year: Int? = nil, month: Int? = nil, day: Int? = nil,
               hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date
    {
        let calendar = Date.sharedCalendar
        var comp = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)

        comp.year = year ?? comp.year
        comp.month = month ?? comp.month
        comp.day = day ?? comp.day
        comp.hour = hour ?? comp.hour
        comp.minute = minute ?? comp.minute
        comp.second = second ?? comp.second

        return calendar.date(from: comp) ?? self
    }

    /// **年月日時分秒を加算**
    func adding(year: Int = 0, month: Int = 0, day: Int = 0,
                hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date
    {
        let calendar = Date.sharedCalendar
        let comp = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        return calendar.date(byAdding: comp, to: self) ?? self
    }
}

// MARK: - Date Components の取得

public extension Date {
    var year: Int { Date.sharedCalendar.component(.year, from: self) }
    var month: Int { Date.sharedCalendar.component(.month, from: self) }
    var day: Int { Date.sharedCalendar.component(.day, from: self) }
    var hour: Int { Date.sharedCalendar.component(.hour, from: self) }
    var minute: Int { Date.sharedCalendar.component(.minute, from: self) }
    var second: Int { Date.sharedCalendar.component(.second, from: self) }

    /// 曜日インデックス（0: 日, 1: 月 ... 6: 土）
    var weekIndex: Int { Date.sharedCalendar.component(.weekday, from: self) - 1 }

    /// 曜日名（例: `"日"` `"月"` `"火"`)
    var weekName: String { ["日", "月", "火", "水", "木", "金", "土"][weekIndex] }
}

// MARK: - 日付操作

public extension Date {
    /// `X` 秒前
    func secondBefore(_ seconds: Int) -> Date { adding(second: -seconds) }

    /// `X` 秒後
    func secondAfter(_ seconds: Int) -> Date { adding(second: seconds) }

    /// `X` 分前
    func minuteBefore(_ minutes: Int) -> Date { adding(minute: -minutes) }

    /// `X` 分後
    func minuteAfter(_ minutes: Int) -> Date { adding(minute: minutes) }

    /// `X` 時間前
    func hourBefore(_ hours: Int) -> Date { adding(hour: -hours) }

    /// `X` 時間後
    func hourAfter(_ hours: Int) -> Date { adding(hour: hours) }

    /// `X` 日前
    func dayBefore(_ days: Int) -> Date { adding(day: -days) }

    /// `X` 日後
    func dayAfter(_ days: Int) -> Date { adding(day: days) }

    /// その日の0時00分
    var startTime: Date { Date.sharedCalendar.startOfDay(for: self) }
}

// MARK: - 年月日ベースの日付操作

public extension Date {
    var yesterday: Date { dayBefore(1) }
    var tomorrow: Date { dayAfter(1) }
    var oneWeekBefore: Date { dayBefore(7) }
    var oneWeekAfter: Date { dayAfter(7) }
    var oneMonthBefore: Date { adding(month: -1) }
    var oneMonthAfter: Date { adding(month: 1) }
    var oneYearBefore: Date { adding(year: -1) }
    var oneYearAfter: Date { adding(year: 1) }

    /// 月初
    var beginningOfTheMonth: Date {
        let comp = Date.sharedCalendar.dateComponents([.year, .month], from: self)
        return Date.sharedCalendar.date(from: comp) ?? self
    }

    /// 月末
    var endOfTheMonth: Date {
        beginningOfTheMonth.adding(month: 1).dayBefore(1)
    }

    /// 年始
    var beginningOfTheYear: Date {
        let comp = Date.sharedCalendar.dateComponents([.year], from: self)
        return Date.sharedCalendar.date(from: comp) ?? self
    }

    /// 年末
    var endOfTheYear: Date {
        beginningOfTheYear.adding(year: 1).dayBefore(1)
    }
}

// MARK: - 日付フォーマット

public extension Date {
    var yyyyMMddHHmmss: String { DateFormatter.yyyyMMddHHmmss.string(from: self) }
    var yyyyMMddHHmm: String { DateFormatter.yyyyMMddHHmm.string(from: self) }
    var yyyyMMdd: String { DateFormatter.yyyyMMdd.string(from: self) }
    var MMdd: String { DateFormatter.MMdd.string(from: self) }
    var HHmm: String { DateFormatter.HHmm.string(from: self) }

    var kanjiyyyyMMddHHmmss: String { DateFormatter.kanjiyyyyMMddHHmmss.string(from: self) }
    var kanjiyyyyMMddHHmm: String { DateFormatter.kanjiyyyyMMddHHmm.string(from: self) }
    var kanjiyyyyMMdd: String { DateFormatter.kanjiyyyyMMdd.string(from: self) }
    var kanjiyyyyMMddE: String { DateFormatter.kanjiyyyyMMddEEE.string(from: self) }

    /// ISO8601 フォーマット（ミリ秒なし）
    var iso8601: String { ISO8601DateFormatter.full.string(from: self) }

    /// ISO8601 フォーマット（ミリ秒あり）
    var iso8601WithMilliseconds: String { ISO8601DateFormatter.fullWithMilliseconds.string(from: self) }
}
