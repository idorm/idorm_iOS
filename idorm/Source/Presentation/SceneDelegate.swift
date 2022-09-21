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
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
    window?.makeKeyAndVisible()
  }
}

extension SceneDelegate {
  func sceneDidEnterBackground(_ scene: UIScene) {
    NotificationCenter.default.post(name: NSNotification.Name("sceneDidEnterBackground"), object: nil)
    UserDefaults.standard.setValue(Date(), forKey: "sceneDidEnterBackground")
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
    guard let start = UserDefaults.standard.object(forKey: "sceneDidEnterBackground") as? Date else { return }
    let interval = Int(Date().timeIntervalSince(start))
    NotificationCenter.default.post(name: NSNotification.Name("sceneWillEnterForeground"), object: nil, userInfo: ["time": interval])
  }
}
