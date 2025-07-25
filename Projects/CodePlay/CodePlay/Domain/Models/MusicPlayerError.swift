//
//  SwiftUIView.swift
//  CodePlay
//
//  Created by 광로 on 7/23/25.
//

import Foundation

// MARK: - Music Player Errors
enum MusicPlayerError: LocalizedError {
    case authorizationRequired
    case trackNotFound(String)
    
    var errorDescription: String? {
        switch self {
        case .authorizationRequired:
            return "Apple Music 권한이 필요합니다"
        case .trackNotFound(let trackId):
            return "곡을 찾을 수 없습니다: \(trackId)"
        }
    }
}
