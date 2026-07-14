import Foundation
import os
import OSLog

// MARK: - OSLog 拡張

public extension OSLog {
    static let ui = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: LoggerCategory.ui.rawValue)
    static let api = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: LoggerCategory.api.rawValue)
    static let network = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: LoggerCategory.network.rawValue)
    static let database = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: LoggerCategory.database.rawValue)
    static let auth = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: LoggerCategory.auth.rawValue)
    static let other = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: LoggerCategory.other.rawValue)
}

// MARK: - ログカテゴリ

/// ログの分類。
///
/// Console.app や `log stream` でカテゴリごとに絞り込める。
/// 分けておかないと、全部のログが 1 本の流れになって追えなくなる。
public enum LoggerCategory: String {
    /// 画面の生成・遷移・ユーザー操作。
    case ui = "UI"

    /// 自分のバックエンドとのやり取り。
    case api = "API"

    /// 通信の下回り（接続状態、再試行など）。API と分けるのは、
    /// 「サーバーが 500 を返した」と「そもそも繋がらない」を区別するため。
    case network = "NETWORK"

    /// ローカル DB / キャッシュ。
    case database = "DATABASE"

    /// ログイン・トークン更新・失効。
    /// **トークンそのものは絶対にログに出さない**（漏洩経路になる）。
    case auth = "AUTH"

    /// 上のどれにも当てはまらないもの。
    case other = "OTHER"
}

// MARK: - OSLogType 拡張（警告回避）

extension OSLogType {
    /// ログレベルを文字列で取得
    var logLevelDescription: String {
        switch self {
        // 通常運転の記録。本番でも残す。
        case .info: return "INFO"

        // 開発時の詳細。本番では出力されない（OS が破棄する）。
        case .debug: return "DEBUG"

        // 想定内の失敗。処理は続行できる。
        case .error: return "ERROR"

        // 想定外の失敗。プログラムの前提が壊れている。
        case .fault: return "FAULT"

        // OSLogType は上記以外の値も取りうる（将来 OS が追加しうる）。
        // 網羅できないので default が要る。
        default: return "DEFAULT"
        }
    }
}

// MARK: - Logger 構造体

public enum Logger {
    /// ログを出すかどうか。
    ///
    /// 可変のグローバル状態なので、ロックで守る。
    /// `nonisolated(unsafe)` だけで通すこともできるが、それは「安全だと
    /// 主張するだけ」で実際には競合しうる。ログはどのスレッドからも
    /// 呼ばれるため、ここは実際に守る。
    public static var isLoggingEnabled: Bool {
        get { lock.withLock { enabled } }
        set { lock.withLock { enabled = newValue } }
    }

    nonisolated(unsafe) private static var enabled = true
    private static let lock = NSLock()

    public static func info(
        category: LoggerCategory = .other,
        message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .info, category: category, message: message, file: file, function: function, line: line)
    }

    public static func debug(
        category: LoggerCategory = .other,
        message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .debug, category: category, message: message, file: file, function: function, line: line)
    }

    public static func warning(
        category: LoggerCategory = .other,
        message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .default, category: category, message: message, file: file, function: function, line: line)
    }

    public static func error(
        category: LoggerCategory = .other,
        message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .error, category: category, message: message, file: file, function: function, line: line)
    }

    public static func fault(
        category: LoggerCategory = .other,
        message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(level: .fault, category: category, message: message, file: file, function: function, line: line)
    }

    private static func log(
        level: OSLogType,
        category: LoggerCategory,
        message: String,
        file: String,
        function: String,
        line: Int
    ) {
        guard isLoggingEnabled else { return }

        let fileName = file.split(separator: "/").last ?? "Unknown"
        let logMessage =
            "[\(category.rawValue)] [\(level.logLevelDescription)] \(fileName):\(line) \(function) -> \(message)"

        #if DEBUG
            let osLog = getOSLog(for: category)
            os_log("%@", log: osLog, type: level, logMessage)
            dump(message)
        #else
            print(logMessage)
        #endif
    }

    private static func getOSLog(for category: LoggerCategory) -> OSLog {
        switch category {
        case .ui: return .ui
        case .api: return .api
        case .network: return .network
        case .database: return .database
        case .auth: return .auth
        case .other: return .other
        }
    }
}
