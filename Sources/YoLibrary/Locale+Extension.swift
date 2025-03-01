import Foundation

// MARK: - Locale 拡張

public extension Locale {
    /// 日本
    static let japan = Locale(identifier: "ja_JP")

    /// アメリカ
    static let us = Locale(identifier: "en_US")

    /// 韓国
    static let korea = Locale(identifier: "ko_KR")

    /// 中国
    static let china = Locale(identifier: "zh_CN")

    /// フランス
    static let france = Locale(identifier: "fr_FR")

    /// ドイツ
    static let germany = Locale(identifier: "de_DE")

    /// イギリス
    static let uk = Locale(identifier: "en_GB")

    /// カナダ
    static let canada = Locale(identifier: "en_CA")

    /// インド
    static let india = Locale(identifier: "hi_IN")

    // MARK: - デバイスの現在のロケール情報

    /// デバイスの現在の言語コード（例: `ja`, `en`, `ko`）
    static var currentLanguageCode: String {
        Locale.current.languageCode ?? "unknown"
    }

    /// デバイスの現在の国コード（例: `JP`, `US`, `KR`）
    static var currentRegionCode: String {
        Locale.current.regionCode ?? "unknown"
    }

    /// 現在のロケールが日本語か
    static var isJapanese: Bool {
        currentLanguageCode == "ja"
    }

    /// 現在のロケールが英語か
    static var isEnglish: Bool {
        currentLanguageCode == "en"
    }

    /// 現在のロケールが韓国語か
    static var isKorean: Bool {
        currentLanguageCode == "ko"
    }
}
