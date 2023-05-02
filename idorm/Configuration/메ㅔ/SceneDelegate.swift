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
  
//  func sceneDidEnterBackground(_ scene: UIScene) {
//    let email = UserStorage.loadEmail()
//    let password = UserStorage.loadPassword()
//    
//    if TokenStorage.hasToken() {
//      // 토큰 Refresh
//      _ = MemberAPI.provider.rx.request(
//        .login(id: email, pw: password)
//      )
//        .asObservable()
//        .retry()
//        .bind { response in
//          switch response.statusCode {
//          case 200..<300:
//            MemberAPI.loginProcess(response)
//          default:
//            break
//          }
//        }
//    }
//  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
    
    // PasteBoard
    let pasteBoard = UIPasteboard.general
    
    guard let string = pasteBoard.string else { return }
    guard string.contains("https://open.kakao.com/") else { return }
    guard let newString = string.checkForUrls.first?.absoluteString else { return }
    
    pasteBoard.string = newString
  }
}
