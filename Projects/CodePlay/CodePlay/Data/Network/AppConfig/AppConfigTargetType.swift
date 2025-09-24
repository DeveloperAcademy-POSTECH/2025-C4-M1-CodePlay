//
//  AppConfigTargetType.swift
//  CodePlay
//
//  Created by 성현 on 9/25/25.
//

import Foundation
import Moya
internal import Alamofire

enum AppConfigTargetType {
    case getAppConfig(platform: String = "ios")
}

extension AppConfigTargetType: BaseTargetType {
    var utilPath: UtilPath { .config }
    var pathParameter: String? { nil }
    var queryParameter: [String: Any]? { nil }
    var requestBodyParameter: Codable? { nil }

    var headerType: [String: String?] {
        ["Accept": "application/json"]
    }

    var path: String {
        switch self {
        case .getAppConfig:
            return "/app-config"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getAppConfig:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .getAppConfig(platform):
            return .requestParameters(
                parameters: ["platform": platform],
                encoding: URLEncoding.queryString
            )
        }
    }
}
