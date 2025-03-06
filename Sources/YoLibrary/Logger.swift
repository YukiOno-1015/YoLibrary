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

public enum LoggerCategory: String {
    case ui = "UI"
    case api = "API"
    case network = "NETWORK"
    case database = "DATABASE"
    case auth = "AUTH"
    case other = "OTHER"
}

// MARK: - OSLogType 拡張（警告回避）

extension OSLogType {
    /// ログレベルを文字列で取得
    var logLevelDescription: String {
        switch self {
        case .info: return "INFO"
        case .debug: return "DEBUG"
        case .error: return "ERROR"
        case .fault: return "FAULT"
        default: return "DEFAULT"
        }
    }
}

// MARK: - Logger 構造体

public enum Logger {
    public static var isLoggingEnabled: Bool = true

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
