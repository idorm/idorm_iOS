import UIKit

import RxSwift
import RxCocoa

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    
    if TokenStorage.shared.loadToken() == "" {
      window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
    } else {
      window?.rootViewController = TabBarController()
    }
    window?.makeKeyAndVisible()
  }
}

// MARK: - Time Checker

extension SceneDelegate {
  func sceneDidEnterBackground(_ scene: UIScene) {
    DeviceManager.shared.startDate = Date()
  }
}
