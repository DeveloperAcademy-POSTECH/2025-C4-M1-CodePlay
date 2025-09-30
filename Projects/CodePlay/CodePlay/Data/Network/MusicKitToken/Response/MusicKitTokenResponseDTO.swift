//
//  MusicKitTokenResponseDTO.swift
//  CodePlay
//
//  Created by 성현 on 9/26/25.
//

import Foundation

struct MusicKitTokenResponseDTO: Decodable {
    let token: String
    let exp: Int

    var expiryDate: Date { Date(timeIntervalSince1970: TimeInterval(exp)) }
}
