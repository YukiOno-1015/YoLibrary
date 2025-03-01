import Foundation
import UIKit

// MARK: - 画面サイズ関連

public enum Screen {
    /// **端末画面の横幅**
    public static let width: CGFloat = UIScreen.main.bounds.width

    /// **端末画面の縦幅**
    public static let height: CGFloat = UIScreen.main.bounds.height

    /// **画面のスケール（Retina, Super Retina 判定用）**
    public static let scale: CGFloat = UIScreen.main.scale

    /// **ノッチがあるデバイスかどうか**
    public static var hasNotch: Bool {
        if #available(iOS 15.0, *) {
            return keyWindow?.safeAreaInsets.bottom ?? 0 > 0
        } else {
            return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0 > 0
        }
    }

    /// **iPad かどうか**
    public static let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad

    /// **iPhone SE などの小さい画面かどうか**
    public static let isSmallScreen: Bool = width < 375

    /// **iPhone Pro Max / iPad などの大画面かどうか**
    public static let isLargeScreen: Bool = width > 414

    /// **ステータスバーの高さ**
    public static var statusBarHeight: CGFloat {
        if #available(iOS 15.0, *) {
            return keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 20
        } else {
            return UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 20
        }
    }

    /// **現在の `keyWindow` を取得**
    private static var keyWindow: UIWindow? {
        if #available(iOS 15.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.windows.first
        }
    }
}
