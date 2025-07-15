//
//  MusicSubscription.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

import Foundation

// MARK: - Domain Model for Music Subscription
struct MusicSubscriptionModel {
    let hasActiveSubscription: Bool
    let isChecking: Bool
    let statusText: String
    let canPlayMusic: Bool
    
    init(hasActiveSubscription: Bool, isChecking: Bool = false) {
        self.hasActiveSubscription = hasActiveSubscription
        self.isChecking = isChecking
        
        if isChecking {
            self.statusText = "구독 상태 확인 중"
        } else if hasActiveSubscription {
            self.statusText = "구독 중"
        } else {
            self.statusText = "구독 없음"
        }
        
        self.canPlayMusic = hasActiveSubscription && !isChecking
    }
}
