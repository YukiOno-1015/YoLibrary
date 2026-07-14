import Foundation

/// API のエラー定義
public enum APIError: Error, Sendable {
    /// URL の組み立てに失敗した。パスやクエリが不正。
    /// 通信は発生していないので、リトライしても無駄。
    case invalidURL

    /// 通信そのものが失敗した（圏外・タイムアウト・DNS 解決不能など）。
    /// サーバーには届いていない可能性が高く、リトライの価値がある。
    case requestFailed(String)

    /// HTTP のレスポンスとして解釈できなかった。通常は起こらない。
    case invalidResponse

    /// レスポンスは受け取ったが、期待した型に復号できなかった。
    /// **サーバーとクライアントの型がずれている**サイン。リトライしても直らない。
    case decodingFailed(String)

    /// 2xx 以外が返った。本文も添える。
    /// 「エラーが起きました」だけでは何が悪いのか調査できないため。
    case statusCode(Int, body: String?)

    /// 401。トークンが切れた、または無効。
    ///
    /// 単なる `statusCode(401)` にしない理由: 呼び出し側は「再ログインへ誘導する」
    /// という特別な扱いをする必要があり、数値を比較させるのは事故のもと。
    case authenticationFailed

    /// エラーメッセージを多言語対応
    public var localizedDescription: String {
        switch self {
        // URL が不正。ユーザーには「設定を確認して」としか言えない。
        case .invalidURL:
            return Utils.localized("invalid_url", bundle: Bundle.yoLibrary)

        // 通信の失敗。原因（圏外など）を添えると、ユーザーが対処できる。
        case let .requestFailed(detail):
            let format = Utils.localized("request_failed", bundle: Bundle.yoLibrary)
            return String(format: format, detail)

        // レスポンスの形が想定外。ユーザーにできることは無い。
        case .invalidResponse:
            return Utils.localized("invalid_response", bundle: Bundle.yoLibrary)

        // 復号の失敗。ユーザーではなく開発者向けの情報なので、詳細を残す。
        case let .decodingFailed(detail):
            let format = Utils.localized("decoding_failed", bundle: Bundle.yoLibrary)
            return String(format: format, detail)

        // サーバーがエラーを返した。本文はここでは出さない
        // （内部の情報がユーザーに見えてしまう）。ログには残っている。
        case let .statusCode(code, _):
            let format = Utils.localized("status_code", bundle: Bundle.yoLibrary)
            return String(format: format, "\(code)")

        // 認証切れ。「再ログインしてください」と伝える。
        case .authenticationFailed:
            return Utils.localized("authentication_failed", bundle: Bundle.yoLibrary)
        }
    }
}

/// HTTP メソッドの定義
public enum HTTPMethod: String, Sendable {
    /// 取得。副作用が無いので、失敗しても安全にリトライできる。
    case get = "GET"

    /// 作成。**冪等ではない**ので、リトライすると二重に作られうる。
    case post = "POST"

    /// 全置換。冪等（同じ内容を何度送っても結果は同じ）。
    case put = "PUT"

    /// 部分更新。送った項目だけを変える。
    case patch = "PATCH"

    /// 削除。冪等（既に無いものを消しても結果は同じ）。
    case delete = "DELETE"
}

/// Content-Type (メディアタイプ)
public enum MediaType: String, Sendable {
    /// JSON。今のところこれしか使わない。
    /// 将来 multipart（画像アップロードなど）を足すならここに追加する。
    case json = "application/json"
}

/// リクエストごとに認証情報を差し込む口。
///
/// **シングルトンに認証を持たせない理由**: トークンは失効し、更新され、
/// ログアウトで消える。`APIClient.shared` に握らせると、その状態管理が
/// ライブラリの中に閉じ込められ、アプリ側から差し替えられなくなる。
///
/// アプリ側は「今のトークンを返す」処理だけを渡す。
/// 期限切れの更新はアプリ（例: Firebase の `getIDToken()`）が面倒を見る。
public protocol AuthTokenProvider: Sendable {
    /// リクエストに付ける認証ヘッダを返す。
    ///
    /// - Returns: ヘッダ名と値の組。認証不要なら空。
    func authorizationHeaders() async throws -> [String: String]
}

/// 認証を付けない場合に使う。
public struct NoAuth: AuthTokenProvider {
    public init() {}

    public func authorizationHeaders() async throws -> [String: String] { [:] }
}

/// 汎用的な API クライアント。
///
/// **`shared` をやめた理由**: ベース URL も認証も環境ごとに変わる。
/// シングルトンだと、テストで差し替えられず、開発用と本番用を同時に
/// 持てない。使う側がインスタンスを持つ。
///
/// `Sendable` なので、どのスレッドから呼んでも安全。
public struct APIClient: Sendable {
    private let baseURL: URL
    private let session: URLSession
    private let auth: AuthTokenProvider
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    /// - Parameters:
    ///   - baseURL: API のベース URL。
    ///   - auth: 認証情報の供給元。不要なら `NoAuth()`。
    ///   - session: 差し替え可能にしてある（テストで `URLProtocol` を挿すため）。
    ///   - decoder: レスポンスの復号。既定は snake_case → camelCase 変換つき。
    ///   - encoder: リクエストの符号化。既定は camelCase → snake_case 変換つき。
    public init(
        baseURL: URL,
        auth: AuthTokenProvider = NoAuth(),
        session: URLSession = .shared,
        decoder: JSONDecoder = .yoDefault,
        encoder: JSONEncoder = .yoDefault
    ) {
        self.baseURL = baseURL
        self.auth = auth
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }

    /// ボディを持つリクエストを送り、結果を復号して返す。
    ///
    /// - Parameters:
    ///   - path: ベース URL からの相対パス（例: `/servers`）。
    ///   - method: HTTP メソッド。
    ///   - body: 送信する値。不要なら nil。
    ///   - query: クエリパラメータ。
    ///   - headers: 追加のヘッダ。認証ヘッダは `auth` から自動で付く。
    /// - Returns: 復号したレスポンス。
    /// - Throws: `APIError`。
    public func request<Response: Decodable & Sendable, Body: Encodable & Sendable>(
        _ path: String,
        method: HTTPMethod,
        body: Body?,
        query: [String: String] = [:],
        headers: [String: String] = [:]
    ) async throws -> Response {
        let request = try await makeRequest(
            path: path,
            method: method,
            bodyData: body.map { try? encoder.encode($0) } ?? nil,
            query: query,
            headers: headers
        )
        let data = try await send(request)

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decodingFailed(error.localizedDescription)
        }
    }

    /// ボディを持たないリクエスト。
    ///
    /// - Parameters:
    ///   - path: ベース URL からの相対パス。
    ///   - method: HTTP メソッド。
    ///   - query: クエリパラメータ。
    ///   - headers: 追加のヘッダ。
    /// - Returns: 復号したレスポンス。
    /// - Throws: `APIError`。
    public func request<Response: Decodable & Sendable>(
        _ path: String,
        method: HTTPMethod = .get,
        query: [String: String] = [:],
        headers: [String: String] = [:]
    ) async throws -> Response {
        let request = try await makeRequest(
            path: path,
            method: method,
            bodyData: nil,
            query: query,
            headers: headers
        )
        let data = try await send(request)

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decodingFailed(error.localizedDescription)
        }
    }

    /// レスポンス本文を使わないリクエスト（DELETE など）。
    ///
    /// - Parameters:
    ///   - path: ベース URL からの相対パス。
    ///   - method: HTTP メソッド。
    ///   - headers: 追加のヘッダ。
    /// - Throws: `APIError`。
    public func send(
        _ path: String,
        method: HTTPMethod,
        headers: [String: String] = [:]
    ) async throws {
        let request = try await makeRequest(
            path: path,
            method: method,
            bodyData: nil,
            query: [:],
            headers: headers
        )
        _ = try await send(request)
    }

    // MARK: - Private

    private func makeRequest(
        path: String,
        method: HTTPMethod,
        bodyData: Data?,
        query: [String: String],
        headers: [String: String]
    ) async throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIError.invalidURL
        }

        if !query.isEmpty {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        if let bodyData {
            request.httpBody = bodyData
            request.setValue(MediaType.json.rawValue, forHTTPHeaderField: "Content-Type")
        }

        // 認証ヘッダを先に付け、呼び出し側の headers で上書きできるようにする。
        for (key, value) in try await auth.authorizationHeaders() {
            request.setValue(value, forHTTPHeaderField: key)
        }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    private func send(_ request: URLRequest) async throws -> Data {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.requestFailed(error.localizedDescription)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // 401 は「トークンが切れた / 無効」。呼び出し側が再ログインに誘導できるよう、
        // ただのステータスコードではなく専用のケースにする。
        guard http.statusCode != 401 else {
            throw APIError.authenticationFailed
        }

        guard (200...299).contains(http.statusCode) else {
            // 本文も添える。「エラーが起きました」だけだと調査できない。
            throw APIError.statusCode(
                http.statusCode,
                body: String(data: data, encoding: .utf8)
            )
        }

        return data
    }
}

// MARK: - JSON の既定設定

extension JSONDecoder {
    /// サーバーの snake_case を Swift の camelCase に変換する既定。
    ///
    /// 日付は ISO8601（ミリ秒あり・なしの両方）を受ける。サーバーの実装で
    /// ミリ秒の有無が揺れることがあり、片方しか受けないと落ちる。
    public static var yoDefault: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let text = try container.decode(String.self)

            if let date = ISO8601DateFormatter.fullWithMilliseconds.date(from: text) {
                return date
            }
            if let date = ISO8601DateFormatter.full.date(from: text) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "ISO8601 として解釈できない日付: \(text)"
            )
        }
        return decoder
    }
}

extension JSONEncoder {
    /// Swift の camelCase をサーバーの snake_case に変換する既定。
    public static var yoDefault: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}
