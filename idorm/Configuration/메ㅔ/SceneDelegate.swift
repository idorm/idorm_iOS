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
    
    window?.rootViewController = LaunchViewController()
    window?.makeKeyAndVisible()
  }
}

// MARK: - URL Schemes

extension SceneDelegate {
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else { return }
    let urlStr = url.absoluteString
    let component = urlStr.components(separatedBy: "=")
    guard let postIdString = component.last else { return }
    guard let postId = Int(postIdString) else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
      TransitionManager.shared.postPushAlarmDidTap?(postId)
    })
  }
}
