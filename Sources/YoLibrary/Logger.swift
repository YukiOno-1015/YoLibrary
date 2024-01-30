//
//  Logger.swift
//  MemoCloud
//
//  Created by yukiono on 2024/01/19.
//
import Foundation
import os
import OSLog

public extension OSLog {
    public static let ui = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "UI")
    public static let api = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "API")
    public static let other = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "OTHER")
}
 
public extension OSLogType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .info:
            return "INFO"
 
        case .debug:
            return "DEBUG"
 
        case .error:
            return "ERROR"
 
        case .fault:
            return "FAULT"
 
        default:
            return "DEFAULT"
        }
    }
}
 
public struct Logger {
    public static func info(
        osLog: OSLog = .default,
        message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        doLog(
            message: message,
            osLog: osLog,
            logType: .info,
            file: file,
            function: function,
            line: line
        )
    }
 
    public static func debug(
        osLog: OSLog = .default,
        message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        doLog(
            message: message,
            osLog: osLog,
            logType: .debug,
            file: file,
            function: function,
            line: line
        )
    }
 
    public static func error(
        osLog: OSLog = .default,
        message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        doLog(
            message: message,
            osLog: osLog,
            logType: .error,
            file: file,
            function: function,
            line: line
        )
    }
 
    public static func fault(
        osLog: OSLog = .default,
        message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        doLog(
            message: message,
            osLog: osLog,
            logType: .fault,
            file: file,
            function: function,
            line: line
        )
    }
 
    private static func doLog(
        message: String,
        osLog: OSLog,
        logType: OSLogType = .default,
        file: String,
        function: String,
        line: Int
    ) {
        #if DEBUG
            os_log(
                "[%@] %@ %@ L:%d ★★★★★★★ %@ ★★★★★★★",
                log: osLog,
                type: logType,
                String(describing: logType),
                file.split(separator: "/").last! as CVarArg,
                function,
                line,
                message
            )
        #endif
    }
}
