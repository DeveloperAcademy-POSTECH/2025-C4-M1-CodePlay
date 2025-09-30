//
//  BaseTargetType.swift
//  CodePlay
//
//  Created by 성현 on 7/24/25.
//

import Foundation
import Moya

enum UtilPath: String {
    case notification = "SNSToken/register"
    case festivalinfo = "festinfo"
    case appleMusicToken = "apple-music"
}

protocol BaseTargetType: TargetType {
    var utilPath: UtilPath { get }
    var pathParameter: String? { get }
    var queryParameter: [String: Any]? { get }
    var requestBodyParameter: Codable? { get }
}

extension BaseTargetType {
    var baseURL: URL {
        guard let baseURL = URL(string: Config.baseURL) else {
            fatalError("🍞⛔️ Base URL이 없어요! ⛔️🍞")
        }
        return baseURL
    }
        
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
