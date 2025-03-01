import Foundation

// MARK: - DateFormatter 拡張

public extension DateFormatter {
    /// 指定したフォーマットで DateFormatter を作成
    private static func create(format: String, locale: Locale = .current) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        formatter.locale = locale
        return formatter
    }

    // MARK: - 標準フォーマット

    /// `yyyy/MM/dd HH:mm:ss`
    static let yyyyMMddHHmmss = create(format: "yyyy/MM/dd HH:mm:ss")

    /// `yyyy/MM/dd HH:mm`
    static let yyyyMMddHHmm = create(format: "yyyy/MM/dd HH:mm")

    /// `yyyy/MM/dd`
    static let yyyyMMdd = create(format: "yyyy/MM/dd")

    /// `MM/dd`
    static let MMdd = create(format: "MM/dd")

    /// `HH:mm`
    static let HHmm = create(format: "HH:mm")

    // MARK: - 和暦フォーマット

    /// `yyyy年MM月dd日 HH時mm分ss秒`
    static let kanjiyyyyMMddHHmmss = create(format: "yyyy年MM月dd日 HH時mm分ss秒")

    /// `yyyy年MM月dd日 HH時mm分`
    static let kanjiyyyyMMddHHmm = create(format: "yyyy年MM月dd日 HH時mm分")

    /// `yyyy年MM月dd日`
    static let kanjiyyyyMMdd = create(format: "yyyy年MM月dd日")

    /// `MM年dd月`
    static let kanjiMMdd = create(format: "MM年dd月")

    /// `HH時mm分`
    static let kanjiHHmm = create(format: "HH時mm分")

    // MARK: - 曜日付きフォーマット（和暦 & 通常）

    /// `yyyy/MM/dd (EEE)`
    static let yyyyMMddEEE = create(format: "yyyy/MM/dd (EEE)", locale: Locale(identifier: "ja_JP"))

    /// `yyyy/MM/dd (EEE) HH:mm`
    static let yyyyMMddEEEHHmm = create(format: "yyyy/MM/dd (EEE) HH:mm", locale: Locale(identifier: "ja_JP"))

    /// `yyyy/MM/dd (EEE) HH:mm:ss`
    static let yyyyMMddEEEHHmmss = create(format: "yyyy/MM/dd (EEE) HH:mm:ss", locale: Locale(identifier: "ja_JP"))

    /// `yyyy年MM月dd日 (EEE)`
    static let kanjiyyyyMMddEEE = create(format: "yyyy年MM月dd日 (EEE)", locale: Locale(identifier: "ja_JP"))

    /// `yyyy年MM月dd日 (EEE) HH時mm分`
    static let kanjiyyyyMMddEEEHHmm = create(format: "yyyy年MM月dd日 (EEE) HH時mm分", locale: Locale(identifier: "ja_JP"))

    /// `yyyy年MM月dd日 (EEE) HH時mm分ss秒`
    static let kanjiyyyyMMddEEEHHmmss = create(format: "yyyy年MM月dd日 (EEE) HH時mm分ss秒", locale: Locale(identifier: "ja_JP"))
}

// MARK: - ISO8601DateFormatter 拡張

public extension ISO8601DateFormatter {
    /// `yyyy-MM-dd'T'HH:mm:ssZ`
    static let full: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withFullDate, .withTime, .withTimeZone,
            .withDashSeparatorInDate, .withColonSeparatorInTime,
        ]
        return formatter
    }()

    /// `yyyy-MM-dd'T'HH:mm:ss.SSSZ`（ミリ秒対応）
    static let fullWithMilliseconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withFullDate, .withTime, .withTimeZone,
            .withDashSeparatorInDate, .withColonSeparatorInTime,
            .withFractionalSeconds,
        ]
        return formatter
    }()

    /// `yyyy-MM-dd`
    static let dateOnly: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        return formatter
    }()
}
