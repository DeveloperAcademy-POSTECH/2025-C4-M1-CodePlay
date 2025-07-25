//
//  FetchFestInfoResponseDTO.swift
//  CodePlay
//
//  Created by 성현 on 7/17/25.
//
import Foundation

/// 디바이스 토큰 전송 후  - 서버 응답용 DTO
struct FetchFestInfoResponseDTO: Decodable {
    let endpointArn: String
}
