import CommonCrypto
import CryptoKit
import Foundation

// MARK: - 🔍 文字列チェック

public extension String {
    /// 空文字またはスペースのみか判定
    var isEmptyOrWhitespace: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// `nil` または空文字か判定
    static func isNilOrEmpty(_ str: String?) -> Bool {
        str?.isEmpty ?? true
    }

    /// `nil` でなく、かつ空文字でないか判定
    static func isNotNilOrEmpty(_ str: String?) -> Bool {
        !isNilOrEmpty(str)
    }

    /// メールアドレス形式かチェック
    var isValidEmail: Bool {
        let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return range(of: regex, options: .regularExpression) != nil
    }

    /// URL 形式かチェック
    var isValidURL: Bool {
        URL(string: self) != nil
    }

    /// 電話番号（数字のみ）かチェック
    var isNumeric: Bool {
        allSatisfy(\.isNumber)
    }
}

// MARK: - 🔎 部分一致チェック

public extension String {
    /// 部分一致チェック（大文字・小文字を区別可能）
    func contains(_ substring: String, caseSensitive: Bool = true) -> Bool {
        caseSensitive ? contains(substring) : range(of: substring, options: .caseInsensitive) != nil
    }
}

// MARK: - 🔄 文字列変換

public extension String {
    /// 半角英数字 ↔ 全角変換
    func transformWidth(toFullWidth: Bool) -> String {
        applyingTransform(.fullwidthToHalfwidth, reverse: toFullWidth) ?? self
    }

    /// Base64 エンコード・デコード
    var base64Encoded: String? { data(using: .utf8)?.base64EncodedString() }
    var base64Decoded: String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// 数値変換
    var toInt: Int? { Int(self) }
    var toDouble: Double? { Double(self) }

    /// URL 変換（形式チェック付き・エラー処理）
    var url: URL {
        guard let validURL = URL(string: self), isValidURL else {
            fatalError("Invalid URL format: \(self)")
        }
        return validURL
    }
}

// MARK: - 🔐 ハッシュ化（SHA256 / MD5）

public extension String {
    /// SHA256 ハッシュ
    var sha256: String {
        if #available(iOS 13, *) {
            return SHA256.hash(data: Data(utf8)).map { String(format: "%02x", $0) }.joined()
        } else {
            return hash(using: CC_SHA256, length: CC_SHA256_DIGEST_LENGTH)
        }
    }

    /// MD5 ハッシュ
    var md5: String {
        if #available(iOS 13, *) {
            return Insecure.MD5.hash(data: Data(utf8)).map { String(format: "%02x", $0) }.joined()
        } else {
            return hash(using: CC_MD5, length: CC_MD5_DIGEST_LENGTH)
        }
    }

    private func hash(
        using function: @escaping (UnsafeRawPointer?, CC_LONG, UnsafeMutablePointer<UInt8>?)
            -> UnsafeMutablePointer<UInt8>?,
        length: Int32
    ) -> String {
        guard let data = data(using: .utf8) else { return "" }
        var hash = [UInt8](repeating: 0, count: Int(length))
        _ = data.withUnsafeBytes { function($0.baseAddress, CC_LONG(data.count), &hash) }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - 📦 JSON 変換

public extension String {
    /// JSON を `Dictionary` または `Array` に変換
    var toJSON: Any? {
        guard let data = data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: [])
    }
}

// MARK: - 🕒 文字列 → 日付変換

public extension String {
    /// 指定フォーマットで `Date` に変換
    func toDate(format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }

    /// ISO8601 形式の日付に変換
    func toISODate() -> Date? {
        ISO8601DateFormatter().date(from: self)
    }
}
