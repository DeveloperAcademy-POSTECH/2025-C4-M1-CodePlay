//
//  DeviceTokenRequestDTO.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/17/25.
//

import Foundation

/// 디바이스 토큰 - 서버 요청용 DTO
struct PostDeviceTokenRequestDTO: Codable {
    let userId: String
    let deviceToken: String
    
    init(user: DeviceInfo) {
        self.userId = user.userId.uuidString // UUID를 String으로 변환
        self.deviceToken = user.deviceToken
    }
}
