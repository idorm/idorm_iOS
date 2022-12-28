//
//  SceneDelegate.swift
//  idorm
//
//  Created by 김응철 on 2022/09/20.
//

import UIKit

import RxSwift
import RxCocoa
import RxMoya

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    
    if TokenStorage.hasToken() {
      window?.rootViewController = TabBarViewController()
    } else {
      let loginVC = LoginViewController()
      loginVC.reactor = LoginViewReactor()
      window?.rootViewController = UINavigationController(rootViewController: loginVC)
    }
    
    window?.makeKeyAndVisible()
  }
}

