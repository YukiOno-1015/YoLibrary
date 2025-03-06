import Foundation
import UIKit

// MARK: - UIDevice Extension

public extension UIDevice {
    /// デバイスの型番を取得
    static var deviceIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let identifier = Mirror(reflecting: systemInfo.machine).children.compactMap { element -> String? in
            guard let value = element.value as? Int8, value != 0 else { return nil }
            return String(UnicodeScalar(UInt8(value)))
        }.joined()
        return identifier
    }

    /// デバイスのモデル名を取得（最新機種含む）
    static var phoneModel: String {
        let identifier = deviceIdentifier
        return deviceMap[identifier] ?? identifier
    }

    /// デバイス識別子とモデル名のマッピング（古い機種も保持）
    private static let deviceMap: [String: String] = [
        // ---- iPhone ----
        "iPhone1,1": "iPhone",
        "iPhone16,1": "iPhone 15 Pro",
        "iPhone16,2": "iPhone 15 Pro Max",
        "iPhone16,3": "iPhone 16",
        "iPhone16,4": "iPhone 16 Plus",
        "iPhone16,5": "iPhone 16 Pro",
        "iPhone16,6": "iPhone 16 Pro Max",

        // ---- iPad ----
        "iPad1,1": "iPad",
        "iPad14,3": "iPad Air 6",
        "iPad14,4": "iPad Air 6",

        // ---- Apple Watch ----
        "Watch1,1": "Apple Watch",
        "Watch6,1": "Apple Watch Series 6",

        // ---- HomePod ----
        "AudioAccessory1,1": "HomePod",
        "AudioAccessory6,1": "HomePod 2",

        // ---- Apple TV ----
        "AppleTV1,1": "Apple TV 1",
        "AppleTV6,3": "Apple TV 4K 3",

        // ---- シミュレーター ----
        "i386": "Simulator",
        "x86_64": "Simulator"
    ]

    /// 現在のデバイスがシミュレーターかどうか
    static var isSimulator: Bool {
        phoneModel == "Simulator"
    }

    /// 現在のデバイスが iPad かどうか
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}

// MARK: - 画面サイズ関連

public extension UIDevice {
    /// 画面の横幅に対する比率でサイズを計算
    static func calcWidth(_ ratio: CGFloat) -> CGFloat {
        UIScreen.main.bounds.width * ratio
    }

    /// 画面の縦幅に対する比率でサイズを計算
    static func calcHeight(_ ratio: CGFloat) -> CGFloat {
        UIScreen.main.bounds.height * ratio
    }
}

// MARK: - UI要素の高さ取得

public extension UIDevice {
    /// ステータスバーの高さ取得（非推奨APIを回避）
    static var statusBarHeight: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.statusBarManager?.statusBarFrame.height }
            .first ?? 0
    }

    /// ナビゲーションバーの高さ取得
    static func navigationBarHeight(in vc: UIViewController) -> CGFloat {
        vc.navigationController?.navigationBar.frame.height ?? 0
    }

    /// ステータスバーとナビゲーションバーの合計高さ取得
    static func headerHeight(in vc: UIViewController) -> CGFloat {
        statusBarHeight + navigationBarHeight(in: vc)
    }

    /// タブバーの高さ取得
    static func tabBarHeight(in vc: UIViewController) -> CGFloat {
        vc.tabBarController?.tabBar.frame.height ?? 0
    }

    /// ステータスバー・ナビゲーションバー・タブバーの合計高さ取得
    static func headerWithTabBarHeight(in vc: UIViewController) -> CGFloat {
        headerHeight(in: vc) + tabBarHeight(in: vc)
    }
}
