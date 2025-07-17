//
//  AppDelegate.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/17/25.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 1. 푸시 권한 요청
        UNUserNotificationCenter.current().delegate = self
        requestAuthorization()
        return true
    }
    
    /// 푸시 권한 요청 함수
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("푸시 권한 거부")
            }
        }
    }
}

extension AppDelegate {
    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("Apns로 받은 디바이스 토큰: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs 등록 및 디바이스 토큰 받기 실패:" + error.localizedDescription)
    }
}
