import Foundation

// MARK: - 📅 Date 操作拡張

public extension Date {
    /// **共通のカレンダー設定（グレゴリオ暦・日本時間）**
    static let sharedCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .japan
        calendar.locale = .japan
        return calendar
    }()

    /// **指定した年月日時分秒で `Date` を作成**
    ///
    /// - Parameters:
    ///   - year: 年（デフォルトは現在の年）
    ///   - month: 月（デフォルトは現在の月）
    ///   - day: 日（デフォルトは現在の日）
    ///   - hour: 時（デフォルトは現在の時）
    ///   - minute: 分（デフォルトは現在の分）
    ///   - second: 秒（デフォルトは現在の秒）
    init(year: Int? = nil, month: Int? = nil, day: Int? = nil,
         hour: Int? = nil, minute: Int? = nil, second: Int? = nil)
    {
        self = Date().fixed(year: year, month: month, day: day,
                            hour: hour, minute: minute, second: second)
    }

    /// **指定した年月日時分秒に固定する**
    ///
    /// - Parameters: `year`, `month`, `day`, `hour`, `minute`, `second`
    /// - Returns: 指定した日時に修正された `Date` インスタンス
    func fixed(year: Int? = nil, month: Int? = nil, day: Int? = nil,
               hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date
    {
        var comp = Date.sharedCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)

        comp.year = year ?? comp.year
        comp.month = month ?? comp.month
        comp.day = day ?? comp.day
        comp.hour = hour ?? comp.hour
        comp.minute = minute ?? comp.minute
        comp.second = second ?? comp.second

        return Date.sharedCalendar.date(from: comp) ?? self
    }

    /// **日付を加算**
    ///
    /// - Parameters: `year`, `month`, `day`, `hour`, `minute`, `second`
    /// - Returns: 指定された期間を加算した `Date`
    func adding(year: Int = 0, month: Int = 0, day: Int = 0,
                hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date
    {
        let comp = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        return Date.sharedCalendar.date(byAdding: comp, to: self) ?? self
    }
}

// MARK: - 📌 日付コンポーネントの取得

public extension Date {
    /// **年**
    var year: Int { Date.sharedCalendar.component(.year, from: self) }

    /// **月**
    var month: Int { Date.sharedCalendar.component(.month, from: self) }

    /// **日**
    var day: Int { Date.sharedCalendar.component(.day, from: self) }

    /// **時**
    var hour: Int { Date.sharedCalendar.component(.hour, from: self) }

    /// **分**
    var minute: Int { Date.sharedCalendar.component(.minute, from: self) }

    /// **秒**
    var second: Int { Date.sharedCalendar.component(.second, from: self) }

    /// **曜日のインデックス（0: 日, 1: 月 ... 6: 土）**
    var weekIndex: Int { Date.sharedCalendar.component(.weekday, from: self) - 1 }

    /// **曜日の名前（例: `"日"` `"月"` `"火"`）**
    var weekName: String { ["日", "月", "火", "水", "木", "金", "土"][weekIndex] }
}

// MARK: - 📅 日付計算

public extension Date {
    /// **指定日数前の日付を取得**
    func dayBefore(_ days: Int) -> Date { adding(day: -days) }

    /// **指定日数後の日付を取得**
    func dayAfter(_ days: Int) -> Date { adding(day: days) }

    /// **その日の午前 0:00**
    var startTime: Date { Date.sharedCalendar.startOfDay(for: self) }
}

// MARK: - 📆 年月日ベースの操作

public extension Date {
    /// **昨日**
    var yesterday: Date { dayBefore(1) }

    /// **明日**
    var tomorrow: Date { dayAfter(1) }

    /// **1ヶ月前**
    var oneMonthBefore: Date { adding(month: -1) }

    /// **1ヶ月後**
    var oneMonthAfter: Date { adding(month: 1) }

    /// **月初（1日）**
    var beginningOfTheMonth: Date {
        let comp = Date.sharedCalendar.dateComponents([.year, .month], from: self)
        return Date.sharedCalendar.date(from: comp) ?? self
    }

    /// **月末**
    var endOfTheMonth: Date {
        beginningOfTheMonth.adding(month: 1).dayBefore(1)
    }
}

// MARK: - 📜 日付フォーマット

public extension Date {
    /// **`yyyy/MM/dd HH:mm:ss` フォーマット**
    var yyyyMMddHHmmss: String { DateFormatter.yyyyMMddHHmmss.string(from: self) }

    /// **和暦 `yyyy年MM月dd日 HH時mm分`**
    var kanjiyyyyMMddHHmm: String { DateFormatter.kanjiyyyyMMddHHmm.string(from: self) }

    /// **ISO8601 フォーマット（ミリ秒なし）**
    var iso8601: String { ISO8601DateFormatter.full.string(from: self) }

    /// **ISO8601 フォーマット（ミリ秒あり）**
    var iso8601WithMilliseconds: String { ISO8601DateFormatter.fullWithMilliseconds.string(from: self) }
}
