//
//  UIColor+Extension.swift
//  YoItems
//
//  Created by Yuki Ono on 2023/04/09.
//

import Foundation
import UIKit

public extension UIColor {
    public convenience init(rgb: Int) {
          let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
          let g = CGFloat((rgb & 0x00FF00) >>  8) / 255.0
          let b = CGFloat( rgb & 0x0000FF       ) / 255.0
          self.init(red: r, green: g, blue: b, alpha: 1.0)
      }
      
    public convenience init(rgba: Int) {
          let r: CGFloat = CGFloat((rgba & 0xFF000000) >> 24) / 255.0
          let g: CGFloat = CGFloat((rgba & 0x00FF0000) >> 16) / 255.0
          let b: CGFloat = CGFloat((rgba & 0x0000FF00) >>  8) / 255.0
          let a: CGFloat = CGFloat( rgba & 0x000000FF       ) / 255.0
          self.init(red: r, green: g, blue: b, alpha: a)
      }
}

public extension UIColor {
    
    public static var backgroundColor: UIColor {
      return UIColor(rgb: 0x9acd32)
    }
    
    public static var memoViewCellBackgroundColor: UIColor {
        return UIColor(rgb: 0x00ffff)
    }
}
