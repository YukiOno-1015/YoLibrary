//
//  File.swift
//  
//
//  Created by yukiono on 2024/01/27.
//

import Foundation
import UIKit

public class Const {
    
    /// 端末画面の横幅
    static let WIDTH = UIScreen.main.bounds.size.width
    /// 端末画面の縦幅
    static let HEIGHT = UIScreen.main.bounds.size.height
    
    // MARK: - 画面共通パラメーター
    /// Cell内オブジェクトの左右の余白
    public static let CELL_MARGIN: CGFloat = 20
    /// Cell（小）の高さ
    public static let CELL_HEIGHT_SMALL: CGFloat = 44
    /// Cell（中）の高さ
    public static let CELL_HEIGHT_MEDIUM: CGFloat = 80
    /// Cell（大）の高さ
    public static let CELL_HEIGHT_LARGE: CGFloat = 100
    /// Cell（特大）の高さ
    public static let CELL_HEIGHT_EXTRA_LARGE: CGFloat = 120
    /// サブヘッダーの高さ
    public static let SUB_HEADER_HEIGHT: CGFloat = 30
    /// サブヘッダーの左右の余白（ボタンを配置する場合に使用）
    static let SUB_HEADER_MARGIN: CGFloat = 10
}
