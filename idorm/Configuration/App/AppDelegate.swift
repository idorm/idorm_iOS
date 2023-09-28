//
//  AppDelegate.swift
//  idorm
//
//  Created by 김응철 on 2022/12/20.
//

import UIKit

import FirebaseCore
import FirebaseMessaging

import KakaoSDKCommon
import KakaoSDKShare
import KakaoSDKTemplate

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    // FCM
    let authOptions = UNAuthorizationOptions([.alert, .badge, .sound])
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions) { _, _ in }
    Messaging.messaging().delegate = self
    application.registerForRemoteNotifications()
    
    // KakaoShare
    KakaoSDK.initSDK(appKey: "a8df1fc9d307130a9d3ee6503549c92b")
    
    // NaivgationBar
    self.setupNavigationBarAppearance()
    self.setupTabBarAppearance()
    return true
  }
}

// MARK: - FCM

// MessagingDelegate 메서드는 FCM에서 알림을 받았을 때 호출됩니다.
// didReceiveRegistrationToken 메서드는 FCM 등록 토큰이 업데이트될 때마다 호출되며,
// 이를 사용하여 FCM 알림을 보낼 때 사용할 수 있는 토큰을 가져옵니다.

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
  // 앱이 Foreground 상태일 때 불려지는 메서드
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([])
  }
  
  // 사용자가 FCM 알림을 탭하여 열 때 호출되는 메서드
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    if let postId = response.notification.request.content.userInfo["contentId"] as? String {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
//        TransitionManager.shared.postPushAlarmDidTap?(Int(postId)!)
      })
    }
  }
  
  // APNs 토큰 설정
  func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
  }
  
  // 토큰 업데이트
  func messaging(
    _ messaging: Messaging,
    didReceiveRegistrationToken fcmToken: String?
  ) {
    FCMTokenManager.shared.fcmToken = fcmToken
  }
}

// MARK: - Setup Appearance

extension AppDelegate {
  private func setupNavigationBarAppearance() {
    let appearance = NavigationAppearanceUtils.navigationAppearance(from: .white, shadow: false)
    UINavigationBar.appearance().compactAppearance = appearance
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
  }
  
  private func setupTabBarAppearance() {
    let tabBarAppearance = UITabBarAppearance()
    let tabBar = UITabBar()
    tabBarAppearance.configureWithOpaqueBackground()
    tabBarAppearance.backgroundColor = .white
    tabBarAppearance.backgroundImage = UIImage()
    tabBarAppearance.shadowImage = UIImage()
    tabBarAppearance.shadowColor = .clear
    tabBar.standardAppearance = tabBarAppearance
    UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    UITabBar.appearance().standardAppearance = tabBarAppearance
  }
}
