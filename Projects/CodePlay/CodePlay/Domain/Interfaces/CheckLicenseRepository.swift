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
    func openAppleMusicSubscriptionPage()
}

final class DefaultCheckLicenseRepository: CheckLicenseRepository {
    func requestMusicAuthorization() async throws -> MusicAuthorizationStatusModel {
        let status = await MusicAuthorization.request()
        return MusicAuthorizationStatusModel(from: status)
    }

    func checkMusicSubscription() async throws -> MusicSubscriptionModel {
        let subscription = try await MusicSubscription.current
        return MusicSubscriptionModel(hasActiveSubscription: subscription.canPlayCatalogContent)
    }

    func fetchCurrentAuthorizationStatus() -> MusicAuthorizationStatusModel {
        let current = MusicAuthorization.currentStatus
        return MusicAuthorizationStatusModel(from: current)
    }

    func openSystemSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }

    func openAppleMusicSubscriptionPage() {
        if let url = URL(string: "https://music.apple.com/subscribe") {
            UIApplication.shared.open(url)
        }
    }
}
