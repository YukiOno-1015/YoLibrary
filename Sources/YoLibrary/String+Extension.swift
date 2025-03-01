import CommonCrypto
import CryptoKit
import Foundation

public extension String {
    // MARK: - 文字列のチェック

    /// **空文字またはスペースのみか判定**
    var isEmptyOrWhitespace: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// **空文字またはスペースのみでないか判定（逆）**
    var isNotEmptyOrWhitespace: Bool {
        !isEmptyOrWhitespace
    }

    /// **`nil` または空文字か判定**
    static func isNilOrEmpty(_ str: String?) -> Bool {
        str?.isEmpty ?? true
    }

    /// **`nil` でなく、かつ空文字でないか判定**
    static func isNotNilOrEmpty(_ str: String?) -> Bool {
        !isNilOrEmpty(str)
    }

    /// **メールアドレス形式かチェック**
    var isValidEmail: Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }

    /// **URL 形式かチェック**
    var isValidURL: Bool {
        URL(string: self) != nil
    }

    /// **電話番号（数字のみ）かチェック**
    var isNumeric: Bool {
        let numRegex = "^[0-9]+$"
        return NSPredicate(format: "SELF MATCHES %@", numRegex).evaluate(with: self)
    }

    // MARK: - 部分一致

    func starts(with prefix: String, caseSensitive: Bool = true) -> Bool {
        caseSensitive ? hasPrefix(prefix) : lowercased().hasPrefix(prefix.lowercased())
    }

    func ends(with suffix: String, caseSensitive: Bool = true) -> Bool {
        caseSensitive ? hasSuffix(suffix) : lowercased().hasSuffix(suffix.lowercased())
    }

    // **部分一致チェック（大文字・小文字を区別可能）**
    func contains(_ substring: String, caseSensitive: Bool = true) -> Bool {
        if caseSensitive {
            return range(of: substring) != nil
        } else {
            return range(of: substring, options: .caseInsensitive) != nil
        }
    }

    // MARK: - 文字列変換

    /// **半角英数字 → 全角変換**
    var toFullWidth: String {
        applyingTransform(.fullwidthToHalfwidth, reverse: true) ?? self
    }

    /// **全角英数字 → 半角変換**
    var toHalfWidth: String {
        applyingTransform(.fullwidthToHalfwidth, reverse: false) ?? self
    }

    var base64Encoded: String? {
        data(using: .utf8)?.base64EncodedString()
    }

    var base64Decoded: String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    var toInt: Int? {
        Int(self)
    }

    var toDouble: Double? {
        Double(self)
    }

    // MARK: - ハッシュ化（SHA256 / MD5）

    var sha256: String {
        guard let data = data(using: .utf8) else { return "" }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { bytes in
            _ = CC_SHA256(bytes.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }

    var md5: String {
        let digest = Insecure.MD5.hash(data: Data(utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - JSON 変換

    var toDictionary: [String: Any]? {
        guard let data = data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    }

    var toArray: [Any]? {
        guard let data = data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: []) as? [Any]
    }

    // MARK: - 文字列 → 日付変換

    func toDate(format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }

    func toDate(format: String, timeZone: TimeZone = .current) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        return formatter.date(from: self)
    }

    func toDate(format: String, locale: Locale = .current) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        return formatter.date(from: self)
    }

    func toISODate() -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: self)
    }
}
