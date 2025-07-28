//
//  PostInfoTargetType.swift
//  CodePlay
//
//  Created by 성현 on 7/25/25.
//

import Foundation
import Moya
internal import Alamofire

enum FestInfoTargetType {
    case postFestInfoText(model: PostFestInfoTextRequestDTO)
}

extension FestInfoTargetType: BaseTargetType {
    var utilPath: UtilPath { return .notification }
    var pathParameter: String? { return .none }
    var queryParameter: [String: Any]? { return .none }
    var requestBodyParameter: Codable? { return .none }
    
    var headerType: [String: String?] {
        switch self {
        case .postFestInfoText:
            return ["Content-Type": "application/json"]
        }
    }
    
    var path: String {
        switch self {
        case .postFestInfoText: return utilPath.rawValue
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postFestInfoText: return .post
        }
    }
    
    var task: Task {
        switch self {
        case let .postFestInfoText(model):
            return .requestJSONEncodable(model)
        }
    }
}
