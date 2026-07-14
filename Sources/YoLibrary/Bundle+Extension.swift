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
        // `ja-JP` → `ja`。lproj のディレクトリ名は地域を含まないため落とす。
        return Locale(identifier: locale).language.languageCode?.identifier ?? "en"
    }

    /// **確実に `Localizable.strings` のバンドルを取得**
    static var yoLibrary: Bundle {
        let bundle = Bundle.module
        let preferredLanguage = preferredLanguageCode

        Logger.debug(message: "🌏 現在の言語: \(preferredLanguage)")

        // 🔥 `resourceURL` を使って `lproj` のフルパスを構築
        if let resourceURL = bundle.resourceURL {
            let lprojPath = resourceURL.appendingPathComponent("Resources/\(preferredLanguage).lproj").path

            Logger.debug(message: "📂 検索パス: \(lprojPath)")

            // `lproj` フォルダが存在するかチェック
            if FileManager.default.fileExists(atPath: lprojPath),
               let localizedBundle = Bundle(path: lprojPath)
            {
                Logger.debug(message: "localizedBundle: \(localizedBundle)")
                return localizedBundle
            }
        }

        return bundle // デフォルトの `Bundle.module` を返す
    }
}
