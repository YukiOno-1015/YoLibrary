import Foundation

// MARK: - 📆 Date 拡張（フォーマット付き）

public extension Date {
    // MARK: - 📜 標準フォーマット

    /// **`yyyy/MM/dd HH:mm:ss` フォーマット**
    var yyyyMMddHHmmss: String { DateFormatter.yyyyMMddHHmmss.string(from: self) }

    /// **`yyyy/MM/dd HH:mm` フォーマット**
    var yyyyMMddHHmm: String { DateFormatter.yyyyMMddHHmm.string(from: self) }

    /// **`yyyy/MM/dd` フォーマット**
    var yyyyMMdd: String { DateFormatter.yyyyMMdd.string(from: self) }

    /// **`MM/dd` フォーマット**
    var MMdd: String { DateFormatter.MMdd.string(from: self) }

    /// **`HH:mm` フォーマット**
    var HHmm: String { DateFormatter.HHmm.string(from: self) }

    // MARK: - 🏯 和暦フォーマット

    /// **和暦 `yyyy年MM月dd日 HH時mm分ss秒`**
    var kanjiyyyyMMddHHmmss: String { DateFormatter.kanjiyyyyMMddHHmmss.string(from: self) }

    /// **和暦 `yyyy年MM月dd日 HH時mm分`**
    var kanjiyyyyMMddHHmm: String { DateFormatter.kanjiyyyyMMddHHmm.string(from: self) }

    /// **和暦 `yyyy年MM月dd日`**
    var kanjiyyyyMMdd: String { DateFormatter.kanjiyyyyMMdd.string(from: self) }

    /// **和暦 `MM年dd月`**
    var kanjiMMdd: String { DateFormatter.kanjiMMdd.string(from: self) }

    /// **和暦 `HH時mm分`**
    var kanjiHHmm: String { DateFormatter.kanjiHHmm.string(from: self) }

    // MARK: - 📅 曜日付きフォーマット（西暦 & 和暦）

    /// **`yyyy/MM/dd (E) HH:mm:ss` フォーマット**
    var yyyyMMddEEEHHmmss: String { DateFormatter.yyyyMMddEEEHHmmss.string(from: self) }

    /// **`yyyy/MM/dd (E) HH:mm` フォーマット**
    var yyyyMMddEEEHHmm: String { DateFormatter.yyyyMMddEEEHHmm.string(from: self) }

    /// **`yyyy/MM/dd (E)` フォーマット**
    var yyyyMMddEEE: String { DateFormatter.yyyyMMddEEE.string(from: self) }

    /// **和暦 `yyyy年MM月dd日 (E) HH:mm:ss` フォーマット**
    var kanjiyyyyMMddEEEHHmmss: String { DateFormatter.kanjiyyyyMMddEEEHHmmss.string(from: self) }

    /// **和暦 `yyyy年MM月dd日 (E) HH:mm` フォーマット**
    var kanjiyyyyMMddEEEHHmm: String { DateFormatter.kanjiyyyyMMddEEEHHmm.string(from: self) }

    /// **和暦 `yyyy年MM月dd日 (E)` フォーマット**
    var kanjiyyyyMMddEEE: String { DateFormatter.kanjiyyyyMMddEEE.string(from: self) }

    // MARK: - ⏳ ISO8601 フォーマット

    /// **ISO8601 フォーマット（ミリ秒なし）**
    var iso8601: String { ISO8601DateFormatter.full.string(from: self) }

    /// **ISO8601 フォーマット（ミリ秒あり）**
    var iso8601WithMilliseconds: String { ISO8601DateFormatter.fullWithMilliseconds.string(from: self) }
}
