import Foundation
import UIKit

// MARK: - UIDevice Extension

extension UIDevice {
    /// デバイスの型番を取得
    public static var deviceIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let identifier = Mirror(reflecting: systemInfo.machine).children
            .compactMap { element -> String? in
                guard let value = element.value as? Int8, value != 0 else {
                    return nil
                }
                return String(UnicodeScalar(UInt8(value)))
            }.joined()
        return identifier
    }

    /// デバイスのモデル名を取得（最新機種含む）
    public static var phoneModel: String {
        let identifier = deviceIdentifier
        return deviceMap[identifier] ?? identifier
    }

    /// デバイス識別子とモデル名のマッピング（サポート切れモデル含む）
    private static let deviceMap: [String: String] = [
        // ---- iPhone ----
        "iPhone1,1": "iPhone",
        "iPhone1,2": "iPhone 3G",
        "iPhone2,1": "iPhone 3GS",
        "iPhone3,1": "iPhone 4",
        "iPhone3,2": "iPhone 4",
        "iPhone3,3": "iPhone 4",
        "iPhone4,1": "iPhone 4S",
        "iPhone5,1": "iPhone 5",
        "iPhone5,2": "iPhone 5",
        "iPhone5,3": "iPhone 5c",
        "iPhone5,4": "iPhone 5c",
        "iPhone6,1": "iPhone 5s",
        "iPhone6,2": "iPhone 5s",
        "iPhone7,1": "iPhone 6 Plus",
        "iPhone7,2": "iPhone 6",
        "iPhone8,1": "iPhone 6s",
        "iPhone8,2": "iPhone 6s Plus",
        "iPhone8,4": "iPhone SE (1st gen)",
        "iPhone9,1": "iPhone 7",
        "iPhone9,2": "iPhone 7 Plus",
        "iPhone9,3": "iPhone 7",
        "iPhone9,4": "iPhone 7 Plus",
        "iPhone10,1": "iPhone 8",
        "iPhone10,2": "iPhone 8 Plus",
        "iPhone10,3": "iPhone X",
        "iPhone10,4": "iPhone 8",
        "iPhone10,5": "iPhone 8 Plus",
        "iPhone10,6": "iPhone X",
        "iPhone11,2": "iPhone XS",
        "iPhone11,4": "iPhone XS Max",
        "iPhone11,6": "iPhone XS Max",
        "iPhone11,8": "iPhone XR",
        "iPhone12,1": "iPhone 11",
        "iPhone12,3": "iPhone 11 Pro",
        "iPhone12,5": "iPhone 11 Pro Max",
        "iPhone12,8": "iPhone SE (2nd gen)",
        "iPhone13,1": "iPhone 12 mini",
        "iPhone13,2": "iPhone 12",
        "iPhone13,3": "iPhone 12 Pro",
        "iPhone13,4": "iPhone 12 Pro Max",
        "iPhone14,2": "iPhone 13 Pro",
        "iPhone14,3": "iPhone 13 Pro Max",
        "iPhone14,4": "iPhone 13 mini",
        "iPhone14,5": "iPhone 13",
        "iPhone14,6": "iPhone SE (3rd gen)",
        "iPhone15,2": "iPhone 14 Pro",
        "iPhone15,3": "iPhone 14 Pro Max",
        "iPhone15,4": "iPhone 14",
        "iPhone15,5": "iPhone 14 Plus",
        "iPhone16,1": "iPhone 15 Pro",
        "iPhone16,2": "iPhone 15 Pro Max",
        "iPhone16,3": "iPhone 16",
        "iPhone16,4": "iPhone 16 Plus",
        "iPhone16,5": "iPhone 16 Pro",
        "iPhone16,6": "iPhone 16 Pro Max",

        // ---- iPad ----
        "iPad1,1": "iPad",
        "iPad2,1": "iPad 2",
        "iPad2,2": "iPad 2",
        "iPad2,3": "iPad 2",
        "iPad2,4": "iPad 2",
        "iPad3,1": "iPad (3rd gen)",
        "iPad3,2": "iPad (3rd gen)",
        "iPad3,3": "iPad (3rd gen)",
        "iPad3,4": "iPad (4th gen)",
        "iPad3,5": "iPad (4th gen)",
        "iPad3,6": "iPad (4th gen)",
        "iPad4,1": "iPad Air",
        "iPad4,2": "iPad Air",
        "iPad4,3": "iPad Air",
        "iPad4,4": "iPad mini 2",
        "iPad4,5": "iPad mini 2",
        "iPad4,6": "iPad mini 2",
        "iPad4,7": "iPad mini 3",
        "iPad4,8": "iPad mini 3",
        "iPad4,9": "iPad mini 3",
        "iPad5,1": "iPad mini 4",
        "iPad5,2": "iPad mini 4",
        "iPad5,3": "iPad Air 2",
        "iPad5,4": "iPad Air 2",
        "iPad6,3": "iPad Pro (9.7-inch)",
        "iPad6,4": "iPad Pro (9.7-inch)",
        "iPad6,7": "iPad Pro (12.9-inch)",
        "iPad6,8": "iPad Pro (12.9-inch)",
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
    public static var isSimulator: Bool {
        phoneModel == "Simulator"
    }

    /// 現在のデバイスが iPad かどうか
    public static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}

// MARK: - 画面サイズ関連

extension UIDevice {
    /// 画面の横幅に対する比率でサイズを計算
    public static func calcWidth(_ ratio: CGFloat) -> CGFloat {
        UIScreen.main.bounds.width * ratio
    }

    /// 画面の縦幅に対する比率でサイズを計算
    public static func calcHeight(_ ratio: CGFloat) -> CGFloat {
        UIScreen.main.bounds.height * ratio
    }
}

// MARK: - UI要素の高さ取得

extension UIDevice {
    /// ステータスバーの高さ取得（非推奨APIを回避）
    public static var statusBarHeight: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap {
                ($0 as? UIWindowScene)?.statusBarManager?.statusBarFrame.height
            }
            .first ?? 0
    }

    /// ナビゲーションバーの高さ取得
    public static func navigationBarHeight(in vc: UIViewController) -> CGFloat {
        vc.navigationController?.navigationBar.frame.height ?? 0
    }

    /// ステータスバーとナビゲーションバーの合計高さ取得
    public static func headerHeight(in vc: UIViewController) -> CGFloat {
        statusBarHeight + navigationBarHeight(in: vc)
    }

    /// タブバーの高さ取得
    public static func tabBarHeight(in vc: UIViewController) -> CGFloat {
        vc.tabBarController?.tabBar.frame.height ?? 0
    }

    /// ステータスバー・ナビゲーションバー・タブバーの合計高さ取得
    public static func headerWithTabBarHeight(in vc: UIViewController)
        -> CGFloat
    {
        headerHeight(in: vc) + tabBarHeight(in: vc)
    }
}
