//
//  MusicAutorizationStatus.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

import Foundation
import MusicKit

// MARK: - Domain Model for Music Authorization
struct MusicAuthorizationStatusModel {
    let status: AuthorizationStatus
    let isAuthorized: Bool
    let statusText: String
    
    enum AuthorizationStatus {
        case notDetermined
        case denied
        case restricted
        case authorized
        case unknown
    }
    
    init(from musicKitStatus: MusicAuthorization.Status) {
        switch musicKitStatus {
        case .notDetermined:
            self.status = .notDetermined
            self.statusText = "권한 요청 필요"
        case .denied:
            self.status = .denied
            self.statusText = "권한 거부됨"
        case .restricted:
            self.status = .restricted
            self.statusText = "권한 제한됨"
        case .authorized:
            self.status = .authorized
            self.statusText = "권한 허용됨"
        @unknown default:
            self.status = .unknown
            self.statusText = "알 수 없음"
        }
        
        self.isAuthorized = musicKitStatus == .authorized
    }
} 
