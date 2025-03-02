import Foundation

/// API のエラー定義
public enum APIError: Error {
    case invalidURL // 無効なURL
    case requestFailed(Error) // リクエスト失敗
    case invalidResponse // 無効なレスポンス
    case decodingFailed(Error) // JSON デコード失敗
    case statusCode(Int) // ステータスコードエラー

    /// エラーメッセージを日本語で表示
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "無効なURLです"
        case let .requestFailed(error):
            return "リクエストに失敗しました: \(error.localizedDescription)"
        case .invalidResponse:
            return "無効なレスポンスです"
        case let .decodingFailed(error):
            return "デコードに失敗しました: \(error.localizedDescription)"
        case let .statusCode(code):
            return "サーバーエラー: ステータスコード \(code)"
        }
    }
}

/// HTTP メソッドの定義（`PUT`, `PATCH`, `DELETE` 追加）
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// Content-Type (メディアタイプ)
public enum MediaType: String {
    case json = "application/json"
}

/// API のエンドポイントを定義
public enum APIEndpoint {
    case memos
}

/// 汎用的な API クライアントクラス
open class APIClient {
    /// シングルトンインスタンス
    static let shared = APIClient()

    /// イニシャライザ（外部からのインスタンス化を防ぐ）
    private init() {}

    /**
     * APIリクエストを実行する汎用メソッド
     *
     * - Parameters:
     *   - url: API のエンドポイント
     *   - method: HTTP メソッド（GET, POST, PUT, DELETE など）
     *   - parameters: API に送信するパラメータ（GETの場合はURLクエリ、POST/PUT/PATCHの場合はボディ）
     *   - headers: 追加のヘッダー情報
     *   - completion: API のレスポンスを非同期で取得するコールバック
     */
    func request<T: Decodable>(
        url: URL,
        method: HTTPMethod,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        var request: URLRequest

        if method == .get, let parameters {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            guard let urlWithQuery = components?.url else {
                completion(.failure(.invalidURL))
                return
            }
            request = URLRequest(url: urlWithQuery)
        } else {
            request = URLRequest(url: url)
            if let parameters {
                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
                if method != .get { // `GET` には `Content-Type` を付けない
                    request.setValue(MediaType.json.rawValue, forHTTPHeaderField: "Content-Type")
                }
            }
        }

        request.httpMethod = method.rawValue

        // ヘッダーを設定
        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        Logger.debug(message: "Request: \(method.rawValue) \(request.url?.absoluteString ?? "No URL")")
        Logger.debug(message: "Headers: \(String(describing: request.allHTTPHeaderFields))")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard self != nil else { return }

            if let error {
                Logger.error(message: "Request Failed: \(error.localizedDescription)")
                completion(.failure(.requestFailed(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            Logger.debug(message: "Response Status: \(httpResponse.statusCode)")

            guard (200 ... 299).contains(httpResponse.statusCode) else {
                completion(.failure(.statusCode(httpResponse.statusCode)))
                return
            }

            guard let data else {
                completion(.failure(.invalidResponse))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                Logger.debug(message: "Decoded Data: \(decodedData)")
                completion(.success(decodedData))
            } catch let decodingError {
                Logger.error(message: "Decoding Failed: \(decodingError)")
                completion(.failure(.decodingFailed(decodingError)))
            }
        }

        task.resume()
    }
}
