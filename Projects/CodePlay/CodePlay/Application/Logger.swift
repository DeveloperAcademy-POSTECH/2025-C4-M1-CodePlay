//
//  Logger.swift
//  CodePlay
//
//  Created by 아우신얀 on 8/11/25.
//

import Foundation
import os.log

struct Log {
    /**
     # (e) Level
     - Authors : suni
     - debug : 디버깅 로그
     - info : 문제 해결 정보
     - fault : 잘못된 정보
     - error :  오류
     - custom(category: String) : 커스텀 디버깅 로그
     */
    enum Level {
        /// 디버깅 로그
        case debug
        /// 문제 해결 정보
        case info
        /// 오류 로그
        case error
        case fault
        case custom(category: String)
        
        fileprivate var category: String {
            switch self {
            case .debug:
                return "🟡 DEBUG"
            case .info:
                return "🟠 INFO"
            case .fault:
                return "🔵 FAULT"
            case .error:
                return "🔴 ERROR"
            case .custom(let category):
                return "🟢 \(category)"
            }
        }
        
        fileprivate var osLog: OSLog {
            switch self {
            case .debug:
                return OSLog.debug
            case .info:
                return OSLog.info
            case .fault:
                return OSLog.fault
            case .error:
                return OSLog.error
            case .custom:
                return OSLog.debug
            }
        }
        
        fileprivate var osLogType: OSLogType {
            switch self {
            case .debug:
                return .debug
            case .info:
                return .info
            case .fault:
                return .fault
            case .error:
                return .error
            case .custom:
                return .debug
            }
        }
    }
    
    static private func log(_ message: Any, level: Level) {
        #if DEBUG
            let logger = Logger(subsystem: OSLog.subsystem, category: level.category)
            let logMessage = "\(level.category): \(message)"
            switch level {
            case .debug,
                 .custom:
                logger.debug("\(logMessage, privacy: .public)")
            case .info:
                logger.info("\(logMessage, privacy: .public)")
            case .fault:
                logger.log("\(logMessage, privacy: .private)")
            case .error:
                logger.error("\(logMessage, privacy: .private)")
            }
        
        #endif
    }
}

// MARK: - extension
extension OSLog {
    static let subsystem = Bundle.main.bundleIdentifier!
    static let fault = OSLog(subsystem: subsystem, category: "Fault")
    static let debug = OSLog(subsystem: subsystem, category: "Debug")
    static let info = OSLog(subsystem: subsystem, category: "Info")
    static let error = OSLog(subsystem: subsystem, category: "Error")
}

extension Log {
    /**
     # debug
     - Note : 개발 중 코드 디버깅 시 사용할 수 있는 유용한 정보
     */
    static func debug(_ message: Any) {
        log(message, level: .debug)
    }

    /**
     # info
     - Note : 문제 해결시 활용할 수 있는, 도움이 되지만 필수적이지 않은 정보
     */
    static func info(_ message: Any) {
        log(message, level: .info)
    }

    /**
     # fault
     - Note : 실행 중 발생하는 버그나 잘못된 동작
     */
    static func fault(_ message: Any) {
        log(message, level: .fault)
    }

    /**
     # error
     - Note : 코드 실행 중 나타난 에러
     */
    static func error(_ message: Any) {
        log(message, level: .error)
    }

    /**
     # custom
     - Note : 커스텀 디버깅 로그
     */
    static func custom(category: String, _ message: Any, _ arguments: Any...) {
        log(message, level: .custom(category: category))
    }
}
