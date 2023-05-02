//
//  AppDelegate.swift
//  idorm
//
//  Created by 김응철 on 2022/12/20.
//

import UIKit

import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Firebase
    FirebaseApp.configure()
    
    // Permission push notifications
    UNUserNotificationCenter.current().delegate = self
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
    application.registerForRemoteNotifications()
    
    Messaging.messaging().delegate = self
    Messaging.messaging().token { token, error in
      if let error = error {
        print("Error fetching FCM registration token: \(error)")
      }
      else if let token = token {
        print("FCM registration token: \(token)")
      }
    }
    
    self.setupNavigationBarAppearance()
    self.setupTabBarAppearance()
    
    return true
  }
}

// MARK: - FCM

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.sound, .badge, .banner])
  }
  
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    completionHandler()
  }
}

extension AppDelegate: MessagingDelegate {
  func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
  }
}

// MARK: - SETUP APPEARANCE

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
