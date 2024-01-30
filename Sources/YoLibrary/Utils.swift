//
//  Utils.swift
//
//
//  Created by yukiono on 2024/01/27.
//

import Foundation
public class Utils {
    public static func postApnsPayload(_ userInfo: Dictionary<String, Any?>) {
        dump(userInfo)
    }
    
    public static func lStr(keyCode: String) -> String {
        return NSLocalizedString(keyCode, comment: "")
    }
    
}
