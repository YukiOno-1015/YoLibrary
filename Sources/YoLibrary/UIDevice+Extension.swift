import UIKit
import SystemConfiguration.CaptiveNetwork

// MARK: - UIDevice

public extension UIDevice {
    
    /// MARK: - デバイスモデルを取得
    /// デバイスの型番を取得するための関数です。
    public static func phoneModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
            case "iPhone1,1":           return "iPhone"
            case "iPhone1,2":           return "iPhone 3G"
            case "iPhone2,1":           return "iPhone 3GS"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":           return "iPhone 4"
            case "iPhone4,1", "iPhone4,2", "iPhone4,3":           return "iPhone 4S"
            case "iPhone5,1", "iPhone5,2":           return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":           return "iPhone 5C"
            case "iPhone6,1", "iPhone6,2":           return "iPhone 5S"
            case "iPhone7,2":           return "iPhone 6"
            case "iPhone7,1":           return "iPhone 6 Plus"
            case "iPhone8,1":           return "iPhone 6S"
            case "iPhone8,2":           return "iPhone 6S Plus"
            case "iPhone8,4":           return "iPhone SE"
            case "iPhone9,1", "iPhone9,3":           return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":           return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":           return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":           return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":           return "iPhone X"
            case "iPhone11,2":           return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":           return "iPhone XS Max"
            case "iPhone11,8":           return "iPhone XR"
            case "iPhone12,1":           return "iPhone 11"
            case "iPhone12,3":           return "iPhone 11 Pro"
            case "iPhone12,5":           return "iPhone 11 Pro Max"
            case "iPhone12,8":           return "iPhone SE 2"
            case "iPhone13,1":           return "iPhone 12 mini"
            case "iPhone13,2":           return "iPhone 12"
            case "iPhone13,3":           return "iPhone 12 Pro"
            case "iPhone13,4":           return "iPhone 12 Pro Max"
            case "iPhone14,4":           return "iPhone 13 mini"
            case "iPhone14,5":           return "iPhone 13"
            case "iPhone14,2":           return "iPhone 13 Pro"
            case "iPhone14,3":           return "iPhone 13 Pro Max"
            case "iPhone14,6":           return "iPhone SE 3"
            case "iPhone14,7":           return "iPhone 14"
            case "iPhone14,8":           return "iPhone 14 Plus"
            case "iPhone15,2":           return "iPhone 14 Pro"
            case "iPhone15,3":           return "iPhone 14 Pro Max"
            case "iPhone15,4":           return "iPhone 15"
            case "iPhone15,5":           return "iPhone 15 Plus"
            case "iPhone16,1":           return "iPhone 15 Pro"
            case "iPhone16,2":           return "iPhone 15 Pro Max"
            case "iPad1,1":           return "iPad"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":           return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad6,11", "iPad6,12":           return "iPad 5"
            case "iPad7,5", "iPad7,6":           return "iPad 6"
            case "iPad7,11", "iPad7,12":           return "iPad 7"
            case "iPad11,6", "iPad11,7":           return "iPad 8"
            case "iPad12,1", "iPad12,2":           return "iPad 9"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":           return "iPad Air 2"
            case "iPad11,3", "iPad11,4":           return "iPad Air 3"
            case "iPad13,1", "iPad13,2":           return "iPad Air 4"
            case "iPad13,16", "iPad13,17":           return "iPad Air 5"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":           return "iPad Mini 4"
            case "iPad11,1", "iPad11,2":           return "iPad Mini 5"
            case "iPad14,1", "iPad14,2":           return "iPad Mini 6"
            case "iPad6,3", "iPad6,4":           return "iPad Pro 9.7-inch"
            case "iPad7,3", "iPad7,4":           return "iPad Pro 10.5-inch"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":           return "iPad Pro 11-inch"
            case "iPad8,9", "iPad8,10":           return "iPad Pro 11-inch 2"
            case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":           return "iPad Pro 11-inch 3"
            case "iPad6,7", "iPad6,8":           return "iPad Pro 12.9-inch"
            case "iPad7,1", "iPad7,2":           return "iPad Pro 12.9-inch 2"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":           return "iPad Pro 12.9-inch 3"
            case "iPad8,11", "iPad8,12":           return "iPad Pro 12.9-inch 4"
            case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":           return "iPad Pro 12.9-inch 5"
            case "iPod1,1":           return "iPod Touch"
            case "iPod2,1":           return "iPod Touch 2"
            case "iPod3,1":           return "iPod Touch 3"
            case "iPod4,1":           return "iPod Touch 4"
            case "iPod5,1":           return "iPod Touch 5"
            case "iPod7,1":           return "iPod Touch 6"
            case "AppleTV1,1":           return "Apple TV 1"
            case "AppleTV2,1":           return "Apple TV 2"
            case "AppleTV3,1", "AppleTV3,2":           return "Apple TV 3"
            case "AppleTV5,3":           return "Apple TV 4"
            case "AppleTV6,2":           return "Apple TV 4K"
            case "AppleTV11,1":           return "Apple TV 4K 2"
            case "Watch1,1", "Watch1,2":           return "Apple Watch"
            case "Watch2,6", "Watch2,7":           return "Apple Watch Series 1"
            case "Watch2,3", "Watch2,4":           return "Apple Watch Series 2"
            case "Watch3,1", "Watch3,2", "Watch3,3", "Watch3,4":           return "Apple Watch Series 3"
            case "Watch4,1", "Watch4,2", "Watch4,3", "Watch4,4":           return "Apple Watch Series 4"
            case "Watch5,1", "Watch5,2", "Watch5,3", "Watch5,4":           return "Apple Watch Series 5"
            case "Watch5,9", "Watch5,10", "Watch5,11", "Watch5,12":           return "Apple Watch SE"
            case "Watch6,1", "Watch6,2", "Watch6,3", "Watch6,4":           return " Apple Watch Series 6"
            case "Watch6,6", "Watch6,7", "Watch6,8", "Watch6,9":           return " Apple Watch Series 7"
            case "AudioAccessory1,1", "AudioAccessory1,2":           return "HomePod"
            case "AudioAccessory5,1":           return "HomePod mini"
            case "i386", "x86_64":           return " Simulator"
            default:                                        return identifier
        }
    }
    
    /// シミュレーターかどうか判定
    /// 現在のデバイスがシミュレーターかどうかを判定する。
    public static var isSimulator: Bool {
        return UIDevice.phoneModel() == "Simulator"
    }
    
    /// iPadかどうか判定
    /// 現在のデバイスがiPadかどうかを判定する。
    public static var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // MARK: - 幅・高さの取得
    
    /// 画面の横幅から比率算出してサイズ取得する
    /// - Parameter num: 端末画面横幅に対する比率
    public class func calcWidth(_ num: CGFloat) -> CGFloat {
        return Const.WIDTH * num
    }
    
    /// 画面の縦幅から比率算出してサイズ取得する
    /// - Parameter num: 端末画面縦幅に対する比率
    public class func calcHeight(_ num: CGFloat) -> CGFloat {
        return Const.HEIGHT * num
    }
    
    /// ステータスバーの高さ取得
    public class func getStatusHei() -> CGFloat {
        return UIApplication.shared.statusBarFrame.size.height
    }
    
    /// ナビゲーションバーの高さ取得
    /// - Parameter vc: vc description
    public class func getNavHei(vc: UIViewController) -> CGFloat {
        return vc.navigationController?.navigationBar.frame.size.height ?? 0
    }
    
    /// ステータスバーとナビゲーションバーの高さの合計取得
    /// - Parameter vc: vc description
    public class func getHeadHei(vc: UIViewController) -> CGFloat {
        return UIDevice.getStatusHei() + UIDevice.getNavHei(vc: vc)
    }
    
    /// タブバーの高さ取得
    /// - Parameter vc: vc description
    public class func getTabBarHei(vc: UIViewController) -> CGFloat {
        return vc.tabBarController?.tabBar.frame.size.height ?? 0
    }
    
    /// ステータスバーとナビゲーションバーとタブバーの高さの合計取得
    /// - Parameter vc: vc description
    public class func getHeadTabHei(vc: UIViewController) -> CGFloat {
        return UIDevice.getHeadHei(vc: vc) + UIDevice.getTabBarHei(vc: vc)
    }
}
