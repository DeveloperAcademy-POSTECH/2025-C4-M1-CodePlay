//
//  AppleMusicConnectViewModel.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

internal import Combine
import Foundation

// MARK: - Input
protocol AppleMusicConnectViewModelInput {
    func requestMusicAuthorization()
    func checkMusicSubscription()
    func updateMusicAuthorizationStatus()
    func openSettings()
    func openAppleMusicSubscription()
}

// MARK: - Output
protocol AppleMusicConnectViewModelOutput {
    var authorizationStatus: Observable<MusicAuthorizationStatusModel?> { get }
    var subscriptionStatus: Observable<MusicSubscriptionModel?> { get }
    var errorMessage: Observable<String?> { get }
    var canPlayMusic: Observable<Bool> { get }
    var shouldRequestMusicAuthorization: Observable<Bool> { get }
    var shouldOpenSettings: Observable<Bool> { get }
}

// MARK: - Unified
protocol AppleMusicConnectViewModel: AppleMusicConnectViewModelInput,
    AppleMusicConnectViewModelOutput, ObservableObject
{}

// MARK: - Implementation
final class DefaultAppleMusicConnectViewModel: AppleMusicConnectViewModel {
    // MARK: Output
    var authorizationStatus: Observable<MusicAuthorizationStatusModel?> =
        Observable(nil)
    var subscriptionStatus: Observable<MusicSubscriptionModel?> = Observable(
        nil
    )
    var errorMessage: Observable<String?> = Observable(nil)
    var canPlayMusic: Observable<Bool> = Observable(false)
    var shouldRequestMusicAuthorization: Observable<Bool> = Observable(false)
    var shouldOpenSettings: Observable<Bool> = Observable(false)

    private let checkLicenseUseCase: CheckLicenseUseCase

    // MARK: Init
    init(checkLicenseUseCase: CheckLicenseUseCase) {
        self.checkLicenseUseCase = checkLicenseUseCase
        observeTriggers()
        updateMusicAuthorizationStatus()
    }

    // MARK: Input

    func requestMusicAuthorization() {
        Task {
            do {
                let (authStatus, subStatus) =
                    try await checkLicenseUseCase.requestMusicAuthorization()

                await MainActor.run {
                    authorizationStatus.value = authStatus
                    errorMessage.value = nil
                    if let sub = subStatus {
                        subscriptionStatus.value = sub
                    }
                }

                updateCanPlayMusic()
            } catch {
                await MainActor.run {
                    errorMessage.value =
                        "권한 요청 중 오류가 발생했습니다: \(error.localizedDescription)"
                }
            }
        }
    }

    func checkMusicSubscription() {
        Task {
            do {
                let subStatus =
                    try await checkLicenseUseCase.checkMusicSubscription()
                await MainActor.run {
                    subscriptionStatus.value = subStatus
                }
                updateCanPlayMusic()
            } catch {
                await MainActor.run {
                    errorMessage.value =
                        "구독 상태 확인 중 오류가 발생했습니다: \(error.localizedDescription)"
                }
            }
        }
    }

    func updateMusicAuthorizationStatus() {
        let status = checkLicenseUseCase.fetchCurrentAuthorizationStatus()
        authorizationStatus.value = status

        if status.isAuthorized {
            checkMusicSubscription()
        } else {
            updateCanPlayMusic()
        }
    }

    func openSettings() {
        checkLicenseUseCase.openSettings()
    }

    func openAppleMusicSubscription() {
        checkLicenseUseCase.openAppleMusicSubscriptionPage()
    }

    // MARK: Private Helpers

    private func updateCanPlayMusic() {
        let isAuthorized = authorizationStatus.value?.isAuthorized ?? false
        let hasSubscription = subscriptionStatus.value?.canPlayMusic ?? false
        canPlayMusic.value = isAuthorized && hasSubscription
    }

    private func observeTriggers() {
        shouldRequestMusicAuthorization.observe(on: self) { [weak self] value in
            guard value else { return }
            self?.shouldRequestMusicAuthorization.value = false
            self?.requestMusicAuthorization()
        }
        
        shouldOpenSettings.observe(on: self) { [weak self] value in
            guard value else { return }
            self?.shouldOpenSettings.value = false
            self?.openSettings()
        }
    }
}
