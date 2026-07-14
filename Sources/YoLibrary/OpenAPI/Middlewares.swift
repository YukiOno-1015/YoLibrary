import Foundation
import HTTPTypes
import OpenAPIRuntime

// swift-openapi-generator と組み合わせて使うミドルウェア。
//
// **生成コードは API ごとに違うが、ここは API に依存しない。**
// だから生成器を使うプロジェクトなら、どれでもそのまま使い回せる。
//
// 生成器を使わない（仕様書が無い）API では、代わりに YoLibrary の
// APIClient を使う。両者は排他ではなく、守備範囲が違う。

// MARK: - 認証

/// 全リクエストに認証ヘッダを付ける。
///
/// トークンの取得・更新はアプリ側の責務にする。ここに Firebase や OAuth の
/// 知識を持ち込むと、ライブラリが特定の認証基盤に縛られる。
public struct AuthMiddleware: ClientMiddleware {
    private let tokenProvider: @Sendable () async throws -> String?

    /// - Parameter tokenProvider: 現在のアクセストークンを返す処理。
    ///   ログイン前など、トークンが無いときは nil を返す。
    ///   **有効期限の更新はここで行う**（例: Firebase の `getIDToken()` は
    ///   期限が近いと自動で更新する）。
    public init(tokenProvider: @escaping @Sendable () async throws -> String?) {
        self.tokenProvider = tokenProvider
    }

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request

        if let token = try await tokenProvider() {
            request.headerFields[.authorization] = "Bearer \(token)"
        }

        return try await next(request, body, baseURL)
    }
}

// MARK: - 相関 ID

/// リクエストに `X-Request-ID` を付ける。
///
/// サーバー側のログ（trace.id）と突き合わせられるようにするためのもの。
/// これが無いと、「アプリでエラーが出た」という報告から、
/// サーバーのどのログを見ればいいかが分からない。
public struct RequestIDMiddleware: ClientMiddleware {
    public init() {}

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request

        let requestID = UUID().uuidString
        request.headerFields[.init("X-Request-ID")!] = requestID

        return try await next(request, body, baseURL)
    }
}

// MARK: - ログ

/// リクエストとレスポンスを記録する。
///
/// **認証ヘッダは出さない**。トークンがログに残ると、それ自体が漏洩経路になる
/// （端末のログは他アプリからは読めないが、共有・添付されうる）。
public struct LoggingMiddleware: ClientMiddleware {
    public init() {}

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        let start = ContinuousClock.now

        do {
            let (response, responseBody) = try await next(request, body, baseURL)
            let elapsed = ContinuousClock.now - start

            Logger.debug(
                category: .api,
                message: "\(operationID) → \(response.status.code) (\(elapsed))"
            )

            return (response, responseBody)
        } catch {
            let elapsed = ContinuousClock.now - start

            Logger.error(
                category: .api,
                message: "\(operationID) → 失敗: \(error.localizedDescription) (\(elapsed))"
            )
            throw error
        }
    }
}

// MARK: - リトライ

/// 一時的な失敗をやり直す。
///
/// **やり直してよい条件を厳しく絞る**。むやみにリトライすると、
/// 「作成」を二重に実行してデータが重複する。
///
///   - GET など副作用の無いメソッドのみ
///   - 5xx（サーバー側の一時的な問題）と通信エラーのみ
///   - 4xx はやり直さない（何度送っても同じ）
public struct RetryMiddleware: ClientMiddleware {
    private let maxAttempts: Int
    private let delay: Duration

    /// - Parameters:
    ///   - maxAttempts: 最初の 1 回を含む試行回数。
    ///   - delay: リトライまでの待ち時間。
    public init(maxAttempts: Int = 3, delay: Duration = .milliseconds(500)) {
        self.maxAttempts = maxAttempts
        self.delay = delay
    }

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        // 副作用のあるメソッドはやり直さない。
        //
        // POST を再送すると、1 回目が実際には成功していた場合に二重登録になる。
        // HTTP はトランザクションではないので、「届いたが応答が返らなかった」の
        // 区別が付かない。
        guard request.method == .get else {
            return try await next(request, body, baseURL)
        }

        // ボディを持つリクエストはやり直さない。
        // HTTPBody は 1 回しか読めないストリームであり、再送できない。
        guard body == nil else {
            return try await next(request, body, baseURL)
        }

        var lastError: Error?

        for attempt in 1...maxAttempts {
            do {
                let (response, responseBody) = try await next(request, body, baseURL)

                // 503 はやり直さない。
                //
                // 5xx の中でこれだけは「意図的に閉じている」意味を持つ
                // （メンテナンス・過負荷）。サーバーは Retry-After で
                // 「いつ来い」と指示しているのに、その場で 3 回叩き直したら
                // 復旧作業中のサーバーに負荷を掛けるだけになる。
                if response.status.code == 503 {
                    return (response, responseBody)
                }

                // 500 / 502 / 504 はサーバー側の一時的な問題。やり直す価値がある。
                // 4xx はこちらの間違いなので、何度送っても同じ。
                if response.status.code >= 500, attempt < maxAttempts {
                    Logger.debug(
                        category: .network,
                        message: "\(operationID) が \(response.status.code)。再試行 \(attempt)/\(maxAttempts)"
                    )
                    try await Task.sleep(for: delay)
                    continue
                }

                return (response, responseBody)
            } catch {
                lastError = error

                guard attempt < maxAttempts else { break }

                Logger.debug(
                    category: .network,
                    message: "\(operationID) が通信エラー。再試行 \(attempt)/\(maxAttempts)"
                )
                try await Task.sleep(for: delay)
            }
        }

        throw lastError ?? APIError.invalidResponse
    }
}
