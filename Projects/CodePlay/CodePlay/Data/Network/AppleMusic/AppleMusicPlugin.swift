//
//  AppleMusicPlugin.swift
//  CodePlay
//
//  Created by 성현 on 9/26/25.
//

import Moya
internal import Alamofire
import Foundation

final class AppleMusicAuthPlugin: PluginType {
    private let tokenAccessor: () -> String?
    init(tokenAccessor: @escaping () -> String?) { self.tokenAccessor = tokenAccessor }

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var r = request
        if let token = tokenAccessor() {
            r.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return r
    }
}

