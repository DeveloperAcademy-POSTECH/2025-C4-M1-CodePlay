//
//  NotificationTargetType.swift
//  CodePlay
//
//  Created by 성현 on 7/25/25.
//

import Foundation
import Moya
internal import Alamofire

enum NotificationTargetType {
    case postDeviceToken(model: PostDeviceTokenRequestDTO)
}

extension NotificationTargetType: BaseTargetType {
    var utilPath: UtilPath { return .notification }
    var pathParameter: String? { return .none }
    var queryParameter: [String: Any]? { return .none }
    var requestBodyParameter: Codable? { return .none }
    
    var headerType: [String: String?] {
        switch self {
        case .postDeviceToken:
            return ["Content-Type": "application/json"]
        }
    }
    
    var path: String {
        switch self {
        case .postDeviceToken: return utilPath.rawValue
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postDeviceToken: return .post
        }
    }
    
    var task: Task {
        switch self {
        case let .postDeviceToken(model):
            return .requestJSONEncodable(model)
        }
    }
}
