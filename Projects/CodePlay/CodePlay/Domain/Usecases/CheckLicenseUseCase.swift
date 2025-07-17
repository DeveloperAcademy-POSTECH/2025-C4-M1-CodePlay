//
//  CheckLicenseUseCase.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

protocol CheckLicenseUseCase {
    func requestMusicAuthorization() async throws -> (MusicAuthorizationStatusModel, MusicSubscriptionModel?)
    func checkMusicSubscription() async throws -> MusicSubscriptionModel
    func fetchCurrentAuthorizationStatus() -> MusicAuthorizationStatusModel
    func openSettings()
    func openAppleMusicSubscriptionPage()
}

final class DefaultCheckLicenseUseCase: CheckLicenseUseCase {
    private let repository: CheckLicenseRepository

    init(repository: CheckLicenseRepository) {
        self.repository = repository
    }

    func requestMusicAuthorization() async throws -> (MusicAuthorizationStatusModel, MusicSubscriptionModel?) {
        let status = try await repository.requestMusicAuthorization()
        if status.isAuthorized {
            let subscription = try await repository.checkMusicSubscription()
            return (status, subscription)
        } else {
            return (status, nil)
        }
    }

    func checkMusicSubscription() async throws -> MusicSubscriptionModel {
        try await repository.checkMusicSubscription()
    }

    func fetchCurrentAuthorizationStatus() -> MusicAuthorizationStatusModel {
        repository.fetchCurrentAuthorizationStatus()
    }

    func openSettings() {
        repository.openSystemSettings()
    }

    func openAppleMusicSubscriptionPage() {
        repository.openAppleMusicSubscriptionPage()
    }
}
