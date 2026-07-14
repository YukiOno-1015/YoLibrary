import Foundation
import HTTPTypes
import OpenAPIRuntime

/// サーバーが掲示しているメンテナンスの情報。
///
/// 本文の形はサーバーと取り決める。ここでは「よくある形」を既定にしている。
public struct MaintenanceInfo: Sendable, Hashable, Codable {
    /// 利用者に見せる文言（日本語）。
    public let message: String?

    /// 利用者に見せる文言（英語）。
    public let messageEn: String?

    /// 終了予定。未定なら nil。
    public let until: Date?

    /// 次に試すまで待つ秒数（HTTP の `Retry-After`）。
    ///
    /// **サーバーが指定した間隔を守ること。**
    /// 勝手に短い間隔で叩き直すと、復旧作業中のサーバーに負荷をかける。
    public let retryAfter: TimeInterval?

    public init(
        message: String?,
        messageEn: String?,
        until: Date?,
        retryAfter: TimeInterval?
    ) {
        self.message = message
        self.messageEn = messageEn
        self.until = until
        self.retryAfter = retryAfter
    }

    private enum CodingKeys: String, CodingKey {
        case message
        case messageEn = "message_en"
        case until
        // retryAfter は本文ではなくヘッダから取る。
        // 本文に書かせると、サーバー側で 2 箇所を同期する羽目になる。
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        messageEn = try container.decodeIfPresent(String.self, forKey: .messageEn)
        until = try container.decodeIfPresent(Date.self, forKey: .until)
        retryAfter = nil
    }
}

/// メンテナンス（HTTP 503）を検知して通知する。
///
/// **API の呼び出し 1 本ずつに 503 の処理を書かせない。**
/// 各画面で `if statusCode == 503` を書くと、必ずどこかで書き漏らして
/// 「その画面だけ意味不明なエラーが出る」ことになる。入口で一度だけ捕まえる。
///
/// 503 はそのまま下流にも流す。呼び出し元がエラーとして扱えるようにするため
/// （握り潰すと、画面は「読み込み中」のまま止まる）。
public struct MaintenanceMiddleware: ClientMiddleware {
    /// メンテナンスを検知したときに呼ぶ処理。
    private let onDetected: @Sendable (MaintenanceInfo) async -> Void

    /// メンテナンスではない応答が返ったときに呼ぶ処理（復帰の検知）。
    private let onRecovered: @Sendable () async -> Void

    /// 本文の日付を読むための変換。
    private let dateTranscoder: any DateTranscoder

    /// - Parameters:
    ///   - dateTranscoder: 本文の `until` を読むのに使う。
    ///     生成した Client と同じものを渡すこと。
    ///   - onDetected: 503 を受け取ったときに呼ばれる。
    ///   - onRecovered: 503 以外が返ったときに呼ばれる。メンテ表示を畳むのに使う。
    public init(
        dateTranscoder: any DateTranscoder = LenientISO8601DateTranscoder(),
        onDetected: @escaping @Sendable (MaintenanceInfo) async -> Void,
        onRecovered: @escaping @Sendable () async -> Void
    ) {
        self.dateTranscoder = dateTranscoder
        self.onDetected = onDetected
        self.onRecovered = onRecovered
    }

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        let (response, responseBody) = try await next(request, body, baseURL)

        guard response.status.code == 503 else {
            await onRecovered()
            return (response, responseBody)
        }

        // 本文を読み切る。HTTPBody は 1 回しか読めないストリームなので、
        // 読んだら同じ内容で作り直して下流に渡す（渡さないと、呼び出し元は
        // 空の本文を受け取る）。
        var collected = Data()
        if let responseBody {
            let bytes = try await ArraySlice(collecting: responseBody, upTo: 64 * 1024)
            collected = Data(bytes)
        }

        // 本文が読めなくてもメンテ扱いは続ける。**503 という事実の方が重い**。
        // 文言が出ないだけで、画面を閉じない理由にはならない。
        let info = decode(collected)

        await onDetected(
            MaintenanceInfo(
                message: info?.message,
                messageEn: info?.messageEn,
                until: info?.until,
                retryAfter: retryAfter(from: response)
            )
        )

        return (response, HTTPBody(collected))
    }

    /// 本文を `MaintenanceInfo` として読む。
    ///
    /// - Parameter data: 503 の本文。
    /// - Returns: 読めた情報。本文が空・壊れている場合は nil。
    private func decode(_ data: Data) -> MaintenanceInfo? {
        guard !data.isEmpty else { return nil }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { [dateTranscoder] decoder in
            let raw = try decoder.singleValueContainer().decode(String.self)
            return try dateTranscoder.decode(raw)
        }

        return try? decoder.decode(MaintenanceInfo.self, from: data)
    }

    /// `Retry-After` ヘッダを秒数として読む。
    ///
    /// - Parameter response: サーバーの応答。
    /// - Returns: 待つべき秒数。ヘッダが無い、または日付形式なら nil。
    private func retryAfter(from response: HTTPResponse) -> TimeInterval? {
        guard
            let field = HTTPField.Name("Retry-After"),
            let raw = response.headerFields[field]
        else {
            return nil
        }

        // RFC 上は秒数でも HTTP-date でもよいが、実運用はほぼ秒数。
        // 日付形式は扱わない（来たら nil にして、既定の間隔で再試行させる）。
        return TimeInterval(raw)
    }
}
