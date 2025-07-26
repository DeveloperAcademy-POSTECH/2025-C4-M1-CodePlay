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
    case postFestInfoVision(model: PostFestInfoVisionRequestDTO)
}

extension FestInfoTargetType: BaseTargetType {
    var utilPath: UtilPath { return .festivalinfo }
    var pathParameter: String? { return .none }
    var queryParameter: [String: Any]? { return .none }
    var requestBodyParameter: Codable? { return .none }
    
    var headerType: [String: String?] {
        switch self {
        case .postFestInfoText:
            return ["Content-Type": "application/json"]
            
        case .postFestInfoVision:
            return ["Content-Type": "application/json"]
        }
    }
    
    var path: String {
        switch self {
        case .postFestInfoText: return utilPath.rawValue + "/search"
        case .postFestInfoVision: return utilPath.rawValue + "/search"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postFestInfoText: return .post
        case .postFestInfoVision: return .post
        }
    }
    
    var task: Task {
        switch self {
        case let .postFestInfoText(model):
            return .requestJSONEncodable(model)
            
        case let .postFestInfoVision(model):
            return .requestJSONEncodable(model)
        }
    }
}
