//
//  CheckLicenseRepository.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//
import MusicKit
import UIKit

protocol CheckLicenseRepository {
    func requestMusicAuthorization() async throws -> MusicAuthorizationStatusModel
    func checkMusicSubscription() async throws -> MusicSubscriptionModel
    func fetchCurrentAuthorizationStatus() -> MusicAuthorizationStatusModel
    func openSystemSettings()
}

final class DefaultCheckLicenseRepository: CheckLicenseRepository {
    // 애플뮤직 권한 요청
    func requestMusicAuthorization() async throws -> MusicAuthorizationStatusModel {
        let status = await MusicAuthorization.request()
        return MusicAuthorizationStatusModel(from: status)
    }

    // 애플뮤직 구독 여부 조회
    func checkMusicSubscription() async throws -> MusicSubscriptionModel {
        let subscription = try await MusicSubscription.current
        return MusicSubscriptionModel(hasActiveSubscription: subscription.canPlayCatalogContent)
    }
    
    // 디바이스에 저장된 애플뮤직 구독 상태
    func fetchCurrentAuthorizationStatus() -> MusicAuthorizationStatusModel {
        let current = MusicAuthorization.currentStatus
        return MusicAuthorizationStatusModel(from: current)
    }
    
    // 시스템 설정 접근
    func openSystemSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}
