//
//  MusicKitTokenTargetType.swift
//  CodePlay
//
//  Created by 성현 on 9/26/25.
//

import Foundation
import Moya
internal import Alamofire

enum MusicKitTokenTargetType {
    case devToken
}

extension MusicKitTokenTargetType: BaseTargetType {
    // DI 시점에 주입 (APIService init에서 세팅)
    static var injectedBaseURL: URL?

    // BaseTargetType 요구사항들
    var utilPath: UtilPath { .appleMusicToken }
    var pathParameter: String? { .none }
    var queryParameter: [String: Any]? { .none }
    var requestBodyParameter: Codable? { .none }

    // 이 타깃만 BaseTargetType의 기본 baseURL을 대체
    var baseURL: URL {
        guard let url = Self.injectedBaseURL else {
            fatalError("🍞⛔️ MusicKitTokenTargetType.injectedBaseURL 미주입 ⛔️🍞")
        }
        return url
    }

    var path: String {
        switch self {
        case .devToken: return utilPath.rawValue // "apple-music"
        }
    }

    var method: Moya.Method {
        switch self {
        case .devToken: return .get
        }
    }

    var task: Task {
        switch self {
        case .devToken: return .requestPlain
        }
    }

    // 컨벤션상 각 타깃에서 headerType을 넣고 있음(실제 사용 헤더는 BaseTargetType.headers)
    var headerType: [String: String?] { ["Content-Type": "application/json"] }

    // 나머지는 BaseTargetType 기본값 사용(sampleData, validationType 등)
}
