import Foundation
import OpenAPIRuntime

/// 小数秒のある・なし、どちらの ISO8601 も読める日付変換。
///
/// **swift-openapi-runtime の既定は小数秒を受け付けない。**
/// 既定は `ISO8601DateFormatter` を `.withInternetDateTime` だけで使うため、
///
///     2026-07-13T23:39:21Z        → 読める
///     2026-07-13T23:39:21.402569Z → DecodingError.dataCorrupted
///
/// になる。ところが Python (FastAPI / Pydantic) や Go、Java の多くは
/// マイクロ秒付きで返す。つまり **既定のままだと、よくあるサーバーの応答が
/// そのままでは decode できない**。
///
/// エラーは "Expected date string to be ISO8601-formatted." としか出ず、
/// どのフィールドが悪いのか分かりにくい。サーバー側で小数秒を削るのは
/// 情報を捨てることになるので、読む側を寛容にする。
///
/// 書き出すときは小数秒を付けない。サーバー側が受け取れない実装があるため、
/// 送るデータは最も素直な形に寄せる。
public struct LenientISO8601DateTranscoder: DateTranscoder {
    /// 小数秒つきを読むための整形器。
    ///
    /// `ISO8601DateFormatter` はスレッドセーフだが `Sendable` ではないので、
    /// コンパイラに安全性を伝える。生成後は設定を変えないため問題ない。
    private nonisolated(unsafe) static let withFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    /// 小数秒なしを読むための整形器。
    private nonisolated(unsafe) static let withoutFraction: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    public init() {}

    /// 日付を文字列にする。
    ///
    /// - Parameter date: 送る日付。
    /// - Returns: 小数秒を含まない ISO8601 の文字列。
    public func encode(_ date: Date) throws -> String {
        Self.withoutFraction.string(from: date)
    }

    /// 文字列を日付にする。
    ///
    /// - Parameter dateString: サーバーが返した ISO8601 の文字列。
    /// - Returns: 変換した日付。
    /// - Throws: どちらの形式でも読めなかったとき。
    public func decode(_ dateString: String) throws -> Date {
        // 小数秒つきを先に試す。サーバーの多くはこちらを返す。
        if let date = Self.withFraction.date(from: dateString) {
            return date
        }

        if let date = Self.withoutFraction.date(from: dateString) {
            return date
        }

        throw DecodingError.dataCorrupted(
            DecodingError.Context(
                codingPath: [],
                debugDescription: "ISO8601 として読めない日付: \(dateString)"
            )
        )
    }
}
