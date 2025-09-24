//
//  AppDelegate.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/17/25.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    private let notificationService: NotificationAPIServiceProtocol = NotificationAPIService()
    
    private let appConfigService: AppConfigAPIServiceProtocol = AppConfigAPIService()
    private var isShowingUpdateAlert = false

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        UNUserNotificationCenter.current().delegate = self
        requestAuthorization()
        
        Task { await checkUpdateGate() }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { await self?.checkUpdateGate() }
        }
        
        return true
    }
    
    func checkUpdateGate() async {
        do {
            let cfg = try await appConfigService.getAppConfig(platform: "ios")
            let current = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0.0.0"
            let minV = cfg.ios.minSupportedVersion

            guard isVersion(current, lowerThan: minV),
                  let url = URL(string: cfg.ios.updateUrl) else { return }

            presentUpdateAlert(force: cfg.ios.force, message: cfg.ios.message, url: url)
        } catch {
            Log.debug("⚠️ GetAppConfig 실패: \(error.localizedDescription)")
        }
    }

    func presentUpdateAlert(force: Bool, message: String, url: URL) {
        guard !isShowingUpdateAlert, let presenter = topMostViewController() else { return }
        isShowingUpdateAlert = true

        let title = force ? "업데이트 필요" : "업데이트 안내"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        if !force {
            alert.addAction(UIAlertAction(title: "나중에", style: .cancel) { [weak self] _ in
                self?.isShowingUpdateAlert = false
            })
        }
        alert.addAction(UIAlertAction(title: "업데이트", style: .default) { [weak self] _ in
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            self?.isShowingUpdateAlert = false
        })

        presenter.present(alert, animated: true)
    }
    
    func topMostViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
        let window = scenes.flatMap({ $0.windows }).first(where: { $0.isKeyWindow })
            ?? scenes.flatMap({ $0.windows }).first

        func climb(_ vc: UIViewController?) -> UIViewController? {
            if let nav = vc as? UINavigationController { return climb(nav.visibleViewController) }
            if let tab = vc as? UITabBarController { return climb(tab.selectedViewController) }
            if let presented = vc?.presentedViewController { return climb(presented) }
            return vc
        }
        return climb(window?.rootViewController)
    }
    
    func isVersion(_ v: String, lowerThan min: String) -> Bool {
        func parts(_ s: String) -> [Int] {
            let p = s.split(separator: ".").compactMap { Int($0) }
            return (p + [0,0,0]).prefix(3).map { $0 }
        }
        let a = parts(v), b = parts(min)
        for i in 0..<3 {
            if a[i] < b[i] { return true }
            if a[i] > b[i] { return false }
        }
        return false
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                Log.debug("❌ 푸시 권한 거부됨")
            }
        }
    }

    /// 포그라운드 수신 시 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        Log.info("🔔 실시간 푸시 수신 (포그라운드): \(userInfo)")
        completionHandler([.banner, .sound, .badge])
    }

    /// 푸시 알림 탭 시 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        Log.debug("🔔 푸시 탭됨: \(userInfo)")
        completionHandler()
    }
}

// MARK: - APNs 등록 처리
extension AppDelegate {
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        Log.debug("📲 APNs 토큰 수신: \(token)")

        // 📌 최초 1회만 서버로 전송
        let hasUploaded = UserDefaults.standard.bool(forKey: "hasUploadedDeviceToken")
        guard !hasUploaded else {
            Log.debug("🔁 이미 업로드된 토큰 → 서버 전송 생략")
            return
        }

        // ✅ userId: 앱 최초 실행 시 UUID 생성 후 고정
        var userIdString = UserDefaults.standard.string(forKey: "userId")
        if userIdString == nil {
            userIdString = UUID().uuidString
            UserDefaults.standard.set(userIdString, forKey: "userId")
        }

        guard let userIdString else { return }

        let deviceInfo = DeviceInfo(userId: UUID(uuidString: userIdString) ?? UUID(),
                                    deviceToken: token)
        let dto = PostDeviceTokenRequestDTO(user: deviceInfo)

        Task {
            do {
                let response = try await notificationService.postDeviceToken(model: dto)
                Log.debug("✅ 서버 등록 성공: \(response.first?.endpointArn ?? "-")")
                UserDefaults.standard.set(true, forKey: "hasUploadedDeviceToken")
            } catch {
                Log.error("❌ 서버에 디바이스 토큰 전송 실패: \(error.localizedDescription)")
            }
        }
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Log.error("❌ APNs 등록 실패: \(error.localizedDescription)")
    }
}
