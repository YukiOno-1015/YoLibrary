import UIKit

// MARK: - UIColor 拡張

public extension UIColor {
    /// RGB (不透明) のカラーを Int で指定
    convenience init(rgb: Int) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }

    /// RGBA のカラーを Int で指定
    convenience init(rgba: Int) {
        self.init(
            red: CGFloat((rgba & 0xFF000000) >> 24) / 255.0,
            green: CGFloat((rgba & 0x00FF0000) >> 16) / 255.0,
            blue: CGFloat((rgba & 0x0000FF00) >> 8) / 255.0,
            alpha: CGFloat(rgba & 0x000000FF) / 255.0
        )
    }

    /// Hex文字列 (`#RRGGBB` or `#RRGGBBAA`) から UIColor を作成
    convenience init?(hexString: String) {
        var hex = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        hex = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex

        guard let hexValue = Int(hex, radix: 16) else { return nil }

        switch hex.count {
        case 6:
            self.init(rgb: hexValue)
        case 8:
            self.init(rgba: hexValue)
        default:
            return nil
        }
    }

    /// UIColor を Hex文字列 (`#RRGGBB` or `#RRGGBBAA`) に変換
    func hexString(includeAlpha: Bool = false) -> String {
        guard let components = cgColor.components, components.count >= 3 else {
            return "#000000"
        }

        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)

        if includeAlpha, components.count >= 4 {
            let a = Int(components[3] * 255)
            return String(format: "#%02X%02X%02X%02X", r, g, b, a)
        }

        return String(format: "#%02X%02X%02X", r, g, b)
    }

    /// 明るさを調整（1.0 以上で明るく、0.0 に近いほど暗くなる）
    func adjustBrightness(_ factor: CGFloat) -> UIColor {
        guard let components = cgColor.components, components.count >= 3 else {
            return self
        }

        let r = min(max(components[0] * factor, 0), 1)
        let g = min(max(components[1] * factor, 0), 1)
        let b = min(max(components[2] * factor, 0), 1)

        return UIColor(red: r, green: g, blue: b, alpha: cgColor.alpha)
    }

    /// 他の UIColor とブレンド
    func blend(with color: UIColor, ratio: CGFloat) -> UIColor {
        let ratio = min(max(ratio, 0), 1)
        guard let c1 = cgColor.components, let c2 = color.cgColor.components, c1.count >= 3, c2.count >= 3 else {
            return self
        }

        let r = c1[0] * (1 - ratio) + c2[0] * ratio
        let g = c1[1] * (1 - ratio) + c2[1] * ratio
        let b = c1[2] * (1 - ratio) + c2[2] * ratio
        let a = cgColor.alpha * (1 - ratio) + color.cgColor.alpha * ratio

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

// MARK: - カラーパレット定義

public extension UIColor {
    static let backgroundColor = UIColor(rgb: 0xF5F5F5)
    static let primaryColor = UIColor(rgb: 0x1E90FF) // 青
    static let secondaryColor = UIColor(rgb: 0x32CD32) // 黄緑
    static let warningColor = UIColor(rgb: 0xFF6347) // 赤

    static let memoViewCellBackgroundColor = UIColor(rgb: 0x00FFFF) // シアン
    static let navigationBarColor = UIColor(rgb: 0x007AFF) // iOS標準の青
    static let tabBarColor = UIColor(rgb: 0x222222) // ダークモード用
}
