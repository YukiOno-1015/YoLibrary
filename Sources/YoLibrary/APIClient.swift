import Foundation

/// API のエラー定義
public enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case statusCode(Int)
    case authenticationFailed

    /// エラーメッセージを多言語対応
    public var localizedDescription: String {
        switch self {
        case .invalidURL:
            return Utils.lstr("invalid_url")

        case let .requestFailed(error):
            let format = Utils.lstr("request_failed")
            return String(format: format, error.localizedDescription)

        case .invalidResponse:
            return Utils.lstr("invalid_response")

        case let .decodingFailed(error):
            let format = Utils.lstr("decoding_failed")
            return String(format: format, error.localizedDescription)

        case let .statusCode(code):
            let format = Utils.lstr("status_code")
            return String(format: format, "\(code)")

        case .authenticationFailed:
            return Utils.lstr("authentication_failed")
        }
    }
}

/// HTTP メソッドの定義
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

/// 汎用的な API クライアントクラス
public final class APIClient {
    /// シングルトンインスタンス
    public static let shared = APIClient()

    /// イニシャライザ（外部からのインスタンス化を防ぐ）
    private init() {}

    /**
     * APIリクエストを実行する汎用メソッド
     *
     * - Parameters:
     *   - url: API のエンドポイントの URL
     *   - method: HTTP メソッド（GET, POST, PUT, DELETE など）
     *   - parameters: API に送信するパラメータ（GET の場合は URL クエリ、POST/PUT/PATCH の場合はボディ）
     *   - headers: 追加のヘッダー情報
     *   - completion: API のレスポンスを非同期で取得するコールバック
     */
    public func request<T: Decodable>(
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
                if method != .get {
                    request.setValue(MediaType.json.rawValue, forHTTPHeaderField: "Content-Type")
                }
            }
        }

        request.httpMethod = method.rawValue

        // ヘッダーを設定
        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(.requestFailed(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.statusCode(httpResponse.statusCode)))
                return
            }

            guard let data else {
                completion(.failure(.invalidResponse))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch let decodingError {
                completion(.failure(.decodingFailed(decodingError)))
            }
        }

        task.resume()
    }
}
