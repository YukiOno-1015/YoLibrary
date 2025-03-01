import Foundation
import UIKit

// MARK: - 画面サイズ関連

public enum Screen {
    /// 端末画面の横幅
    public static let width: CGFloat = UIScreen.main.bounds.width

    /// 端末画面の縦幅
    public static let height: CGFloat = UIScreen.main.bounds.height

    /// 画面のスケール（Retina, Super Retina 判定用）
    public static let scale: CGFloat = UIScreen.main.scale

    /// 小さい画面かどうか（例: iPhone SE など）
    public static let isSmallScreen: Bool = width < 375

    /// 大きい画面かどうか（例: iPhone Pro Max / iPad）
    public static let isLargeScreen: Bool = width > 414
}

// MARK: - Cell の高さを管理

public enum CellHeight {
    /// Cell の左右の余白
    public static let margin: CGFloat = 20

    /// Cell の高さ（サイズ別）
    public static let small: CGFloat = 44
    public static let medium: CGFloat = 80
    public static let large: CGFloat = 100
    public static let extraLarge: CGFloat = 120
}

// MARK: - UI 共通定数

public enum UIConstants {
    /// サブヘッダーの高さ
    public static let subHeaderHeight: CGFloat = 30

    /// サブヘッダーの左右の余白（ボタン配置用）
    public static let subHeaderMargin: CGFloat = 10
}
