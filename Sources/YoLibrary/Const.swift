import Foundation
import UIKit

// MARK: - 画面サイズ関連

/// 画面まわりの値。
///
/// **`@MainActor` にした理由**: `UIScreen` / `UIApplication` は UI の状態で、
/// メインスレッド以外から触ると未定義動作になる。Swift 6 なら型で縛れる。
///
/// **`static let` をやめた理由**: 以前は起動時の値を定数として持っていたが、
/// Split View・Stage Manager・画面回転で**平気で変わる**。定数にすると
/// 画面を分割した瞬間に嘘の値を返す。都度取り直す `var` にした。
@MainActor
public enum Screen {
    /// **端末画面の横幅**
    ///
    /// `UIScreen.main` は iOS 16 で非推奨。マルチウィンドウでは「どの画面か」が
    /// 一意に決まらないため、実際に表示中の window から取る。
    public static var width: CGFloat { keyWindow?.bounds.width ?? 0 }

    /// **端末画面の縦幅**
    public static var height: CGFloat { keyWindow?.bounds.height ?? 0 }

    /// **画面のスケール（Retina, Super Retina 判定用）**
    public static var scale: CGFloat { keyWindow?.screen.scale ?? 1 }

    /// **ノッチ（またはホームインジケータ）があるか**
    public static var hasNotch: Bool {
        (keyWindow?.safeAreaInsets.bottom ?? 0) > 0
    }

    /// **iPad かどうか**
    public static var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }

    /// **iPhone SE などの小さい画面かどうか**
    public static var isSmallScreen: Bool { width < 375 }

    /// **iPhone Pro Max / iPad などの大画面かどうか**
    public static var isLargeScreen: Bool { width > 414 }

    /// **ステータスバーの高さ**
    public static var statusBarHeight: CGFloat {
        keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }

    /// **セーフエリアの余白**
    public static var safeAreaInsets: UIEdgeInsets {
        keyWindow?.safeAreaInsets ?? .zero
    }

    /// **現在表示中の window**
    ///
    /// 前景でアクティブなシーンから取る。バックグラウンドのシーンを掴むと
    /// 画面外のサイズを返してしまう。
    public static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
    }
}
