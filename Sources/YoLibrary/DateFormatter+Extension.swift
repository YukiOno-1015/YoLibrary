import Foundation

// MARK: - DateFormatter 拡張

public extension DateFormatter {
    /// 指定したフォーマットとロケールで DateFormatter を作成
    private static func createFormatter(format: String, locale: Locale = .current) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        formatter.locale = locale
        return formatter
    }

    // MARK: - 標準フォーマット

    static let yyyyMMddHHmmss: DateFormatter = createFormatter(format: "yyyy/MM/dd HH:mm:ss")
    static let yyyyMMddHHmm: DateFormatter = createFormatter(format: "yyyy/MM/dd HH:mm")
    static let yyyyMMdd: DateFormatter = createFormatter(format: "yyyy/MM/dd")
    static let MMdd: DateFormatter = createFormatter(format: "MM/dd")
    static let HHmm: DateFormatter = createFormatter(format: "HH:mm")

    // MARK: - 和暦フォーマット

    static let kanjiyyyyMMddHHmmss: DateFormatter = createFormatter(format: "yyyy年MM月dd日 HH時mm分ss秒")
    static let kanjiyyyyMMddHHmm: DateFormatter = createFormatter(format: "yyyy年MM月dd日 HH時mm分")
    static let kanjiyyyyMMdd: DateFormatter = createFormatter(format: "yyyy年MM月dd日")
    static let kanjiMMdd: DateFormatter = createFormatter(format: "MM年dd月")
    static let kanjiHHmm: DateFormatter = createFormatter(format: "HH時mm分")

    // MARK: - 曜日付きフォーマット

    static let yyyyMMddEEE: DateFormatter = createFormatter(format: "yyyy/MM/dd (EEE)", locale: .japan)
    static let kanjiyyyyMMddEEE: DateFormatter = createFormatter(format: "yyyy年MM月dd日 (EEE)", locale: .japan)
}

// MARK: - ISO8601DateFormatter 拡張

public extension ISO8601DateFormatter {
    /// ISO8601 フルフォーマット（`yyyy-MM-dd'T'HH:mm:ssZ`）
    static let full: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withFullDate, .withTime, .withTimeZone,
            .withDashSeparatorInDate, .withColonSeparatorInTime,
        ]
        return formatter
    }()

    /// ISO8601 ミリ秒付きフォーマット（`yyyy-MM-dd'T'HH:mm:ss.SSSZ`）
    static let fullWithMilliseconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withFullDate, .withTime, .withTimeZone,
            .withDashSeparatorInDate, .withColonSeparatorInTime,
            .withFractionalSeconds, // ★ ミリ秒対応
        ]
        return formatter
    }()

    /// ISO8601 簡易フォーマット（`yyyy-MM-dd`）
    static let dateOnly: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate]
        return formatter
    }()
}
