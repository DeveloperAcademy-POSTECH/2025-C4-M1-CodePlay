//
//  DeviceTokenResponseDTO.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/17/25.
//
import Foundation

/// 디바이스 토큰 전송 후  - 서버 응답용 DTO
struct PostDeviceTokenResponseDTO: Decodable {
    let endpointArn: String
}
