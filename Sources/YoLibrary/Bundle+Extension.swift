//
//  Bundle+Extension.swift
//  YoLibrary
//
//  Created by honoka on 2025/03/09.
//

import Foundation

public extension Bundle {
    /// **`Locale` の言語コードを `ja` などの一般的な形式に変換**
    ///
    /// - Returns: `"ja"`, `"en"` などの基本的な言語コード
    static var preferredLanguageCode: String {
        let locale = Locale.preferredLanguages.first ?? "en"
        return Locale(identifier: locale).languageCode ?? "en" // `ja-JP` → `ja`
    }

    static var yoLibrary: Bundle {
        let bundle = Bundle.module
        let preferredLanguage = preferredLanguageCode ?? "en"

        Logger.debug(message: "🌏 現在の言語: \(preferredLanguage)")
        Logger.debug(message: bundle.path(forResource: preferredLanguage, ofType: "lproj") ?? "なし")
        if let path = bundle.path(forResource: preferredLanguage, ofType: "lproj"),
           let localizedBundle = Bundle(path: path)
        {
            return localizedBundle
        }

        return bundle
    }
}
