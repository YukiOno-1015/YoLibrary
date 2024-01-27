//
//  Utils.swift
//  
//
//  Created by yukiono on 2024/01/27.
//

import Foundation
public class Utils {
    public func postApnsPayload(userInfo:[AnyHashable: Any]) {
        dump(userInfo)
    }
    
    public func Localization(keyCode: String) -> String {
        return NSLocalizedString(keyCode, comment: "")
    }
    
}
