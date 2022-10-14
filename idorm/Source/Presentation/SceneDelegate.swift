//
//  SceneDelegate.swift
//  idorm
//
//  Created by 김응철 on 2022/07/08.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  
  //MARK: - Init VC
  
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    
    if TokenManager.loadToken() == "" {
      window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
    } else {
      window?.rootViewController = UINavigationController(rootViewController: OnboardingViewController(type: .firstTime))
    }
    
    window?.makeKeyAndVisible()
  }
}

// MARK: - Time Checker

extension SceneDelegate {
  func sceneDidEnterBackground(_ scene: UIScene) {
    NotificationCenter.default.post(
      name: NSNotification.Name(MailTimerChecker.Keys.sceneDidEnterBackground.value),
      object: nil
    )
    UserDefaults.standard.setValue(Date(), forKey: MailTimerChecker.Keys.sceneDidEnterBackground.value)
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
    guard let start = UserDefaults.standard.object(
      forKey: MailTimerChecker.Keys.sceneDidEnterBackground.value
    ) as? Date else {
      return
    }
    
    let interval = Int(Date().timeIntervalSince(start))
    NotificationCenter.default.post(
      name: NSNotification.Name(MailTimerChecker.Keys.sceneWillEnterForeground.value),
      object: nil,
      userInfo: ["time": interval]
    )
  }
}
