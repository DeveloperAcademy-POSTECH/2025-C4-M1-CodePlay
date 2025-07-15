//
//  AppleMusicConnectViewModel.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

import Foundation
import UIKit
internal import Combine
import MusicKit

// MARK: AppleMusicConnectViewModelInput
protocol AppleMusicConnectViewModelInput {
    /// 음악 권한을 요청하는 함수
    func requestMusicAuthorization()
    /// 음악 구독 상태를 확인하는 함수
    func checkMusicSubscription()
    /// 음악 권한 상태를 업데이트하는 함수
    func updateMusicAuthorizationStatus()
    /// 설정 앱으로 이동하는 함수
    func openSettings()
    /// Apple Music 구독 페이지로 이동하는 함수
    func openAppleMusicSubscription()
}

// MARK: AppleMusicConnectViewModelOutput
protocol AppleMusicConnectViewModelOutput {
    var authorizationStatus: Observable<MusicAuthorizationStatusModel?> { get }
    var subscriptionStatus: Observable<MusicSubscriptionModel?> { get }
    var errorMessage: Observable<String?> { get }
    var canPlayMusic: Observable<Bool> { get }
}

// MARK: AppleMusicConnectViewModel
protocol AppleMusicConnectViewModel: AppleMusicConnectViewModelInput, AppleMusicConnectViewModelOutput, ObservableObject { }

// MARK: DefaultAppleMusicConnectViewModel
final class DefaultAppleMusicConnectViewModel: AppleMusicConnectViewModel {
    var authorizationStatus: Observable<MusicAuthorizationStatusModel?> = Observable(nil)
    var subscriptionStatus: Observable<MusicSubscriptionModel?> = Observable(nil)
    var errorMessage: Observable<String?> = Observable(nil)
    var canPlayMusic: Observable<Bool> = Observable(false)
    
    init() {
        updateMusicAuthorizationStatus()
    }
    
    func requestMusicAuthorization() {
        print("🎵 권한 요청 시작")
        
        #if DEBUG
        // Preview/시뮬레이터에서는 Mock 상태 사용
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            print("🎵 Preview 모드 - Mock 권한 승인")
            let mockStatus = MusicAuthorizationStatusModel(from: .authorized)
            let mockSubscription = MusicSubscriptionModel(hasActiveSubscription: true)
            
            authorizationStatus.value = mockStatus
            subscriptionStatus.value = mockSubscription
            canPlayMusic.value = true
            return
        }
        #endif
        
        Task {
            do {
                let status = await MusicAuthorization.request()
                print("🎵 권한 요청 결과: \(status)")
                
                await MainActor.run {
                    let statusModel = MusicAuthorizationStatusModel(from: status)
                    authorizationStatus.value = statusModel
                    errorMessage.value = nil
                }
                
                if status == .authorized {
                    print("🎵 권한 승인됨 - 구독 상태 확인 시작")
                    checkMusicSubscription()
                }
                
                updateCanPlayMusic()
            } catch {
                print("🎵 권한 요청 오류: \(error)")
                await MainActor.run {
                    errorMessage.value = "권한 요청 중 오류가 발생했습니다: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func checkMusicSubscription() {
        print("🎵 구독 상태 확인 시작")
        
        #if DEBUG
        // Preview에서는 Mock 상태 사용
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            print("🎵 Preview 모드 - Mock 구독 상태")
            let mockSubscription = MusicSubscriptionModel(hasActiveSubscription: true)
            subscriptionStatus.value = mockSubscription
            canPlayMusic.value = true
            return
        }
        #endif
        
        // 구독 확인 중 상태로 설정
        let checkingSubscription = MusicSubscriptionModel(hasActiveSubscription: false, isChecking: true)
        subscriptionStatus.value = checkingSubscription
        errorMessage.value = nil
        
        Task {
            do {
                let subscription = try await MusicSubscription.current
                let canPlay = subscription.canPlayCatalogContent
                print("🎵 구독 상태 확인 완료: \(canPlay)")
                
                await MainActor.run {
                    let subscriptionModel = MusicSubscriptionModel(hasActiveSubscription: canPlay)
                    subscriptionStatus.value = subscriptionModel
                }
                
                updateCanPlayMusic()
            } catch {
                let errorMsg = "구독 상태를 확인할 수 없습니다: \(error.localizedDescription)"
                print("🎵 구독 상태 확인 오류: \(errorMsg)")
                
                await MainActor.run {
                    errorMessage.value = errorMsg
                    let subscriptionModel = MusicSubscriptionModel(hasActiveSubscription: false)
                    subscriptionStatus.value = subscriptionModel
                }
                
                updateCanPlayMusic()
            }
        }
    }
    
    func updateMusicAuthorizationStatus() {
        #if DEBUG
        // Preview에서는 Mock 상태 사용
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            let mockStatus = MusicAuthorizationStatusModel(from: .notDetermined)
            authorizationStatus.value = mockStatus
            return
        }
        #endif
        
        let currentStatus = MusicAuthorization.currentStatus
        let statusModel = MusicAuthorizationStatusModel(from: currentStatus)
        authorizationStatus.value = statusModel
        
        if currentStatus == .authorized {
            checkMusicSubscription()
        }
        
        updateCanPlayMusic()
    }
    
    func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    func openAppleMusicSubscription() {
        if let url = URL(string: "https://music.apple.com/subscribe") {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Private Methods
    private func updateCanPlayMusic() {
        let isAuthorized = authorizationStatus.value?.isAuthorized ?? false
        let hasSubscription = subscriptionStatus.value?.canPlayMusic ?? false
        canPlayMusic.value = isAuthorized && hasSubscription
    }
}
