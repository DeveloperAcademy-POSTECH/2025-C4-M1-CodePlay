//
//  GetAppConfigResponseDTO.swift
//  CodePlay
//
//  Created by 성현 on 9/25/25.
//

import Foundation

struct GetAppConfigResponseDTO: Decodable {
    struct Platform: Decodable {
        let minSupportedVersion: String
        let force: Bool
        let message: String
        let updateUrl: String
    }
    let ios: Platform
}
