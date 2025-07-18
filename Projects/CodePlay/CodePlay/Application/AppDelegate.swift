//
//  AppDelegate.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/17/25.
//

import UIKit
import SwiftData

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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("🔔 실시간 푸시 수신 (포그라운드) - userInfo:", userInfo)
                
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("🔔 푸시 탭됨 - userInfo:", userInfo)
                
        completionHandler()
    }
    
    func saveDeviceInfo(userId: UUID, token: String, context: ModelContext) {
        let info = DeviceInfo(userId: userId, deviceToken: token)
        context.insert(info)
        
        do {
            try context.save()
        } catch {
            print("디바이스 토큰 저장 안됨: \(error)")
        }
    }
}

extension AppDelegate {
    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("Apns로 받은 디바이스 토큰: \(token)")
        
        // 토큰 저장
        UserDefaults.standard.set(token, forKey: "deviceToken")
        
        // 서버에 디바이스 토큰 post
        let userId = UUID()
        let deviceInfo = DeviceInfo(userId: userId, deviceToken: token)
        let dto = DeviceTokenRequestDTO(user: deviceInfo)
        
        let service = DefaultNotificationAPIService(session: URLSession.shared)
        Task {
            do {
                let response = try await service.postDeviceToken(model: dto)
                print("서버 등록 성공: \(response.endpointArn)")
            } catch {
                print("서버에 디바이스 토큰 전송 실패: \(error)")
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs 등록 및 디바이스 토큰 받기 실패:" + error.localizedDescription)
    }
}
