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
    
    let viewController = iDormTabBarViewController()
//    viewController.reactor = idormtabbar
    window?.rootViewController = UINavigationController(rootViewController: viewController)
    window?.makeKeyAndVisible()
    
    let url = connectionOptions.urlContexts.first?.url
    KakaoShareManager.shared.handleKakaoMessageDeepLink(url)
  }
  
  func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    let url = URLContexts.first?.url
    KakaoShareManager.shared.handleKakaoMessageDeepLink(url)
  }
}
