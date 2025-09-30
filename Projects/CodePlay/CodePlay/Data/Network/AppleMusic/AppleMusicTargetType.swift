//
//  AppleMusicTargetType.swift
//  CodePlay
//
//  Created by 성현 on 9/26/25.
//

import Moya
internal import Alamofire
import Foundation

enum AppleMusicTargetType {
    case search(term: String, types: [String], limit: Int, storefront: String)
    case artistTopSongs(artistId: String, limit: Int, storefront: String)
}

extension AppleMusicTargetType: TargetType {
    var baseURL: URL { URL(string: "https://api.music.apple.com/v1")! }
    var path: String {
        switch self {
        case let .search(_, _, _, sf):        return "/catalog/\(sf)/search"
        case let .artistTopSongs(id, _, sf):  return "/catalog/\(sf)/artists/\(id)/view/top-songs"
        }
    }
    var method: Moya.Method { .get }
    var task: Task {
        switch self {
        case let .search(term, types, limit, _):
            return .requestParameters(parameters: [
                "term": term,
                "types": types.joined(separator: ","),
                "limit": limit
            ], encoding: URLEncoding.queryString)
        case let .artistTopSongs(_, limit, _):
            return .requestParameters(parameters: ["limit": limit], encoding: URLEncoding.queryString)
        }
    }
    var headers: [String: String]? { ["Content-Type": "application/json"] }
    var sampleData: Data { Data() }
}
