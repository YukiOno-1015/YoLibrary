//
//  Bundle+Extension.swift
//  YoLibrary
//
//  Created by honoka on 2025/03/09.
//

import Foundation

public extension Bundle {
    static var yoLibrary: Bundle {
        let bundle = Bundle.module
        let preferredLanguage = Locale.preferredLanguages.first ?? "en"

        if let path = bundle.path(forResource: preferredLanguage, ofType: "lproj"),
           let localizedBundle = Bundle(path: path)
        {
            return localizedBundle
        }

        return bundle
    }
}
