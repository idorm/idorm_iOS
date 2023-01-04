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
  
  func sceneDidEnterBackground(_ scene: UIScene) {
    let email = UserStorage.loadEmail()
    let password = UserStorage.loadPassword()
    
    if TokenStorage.hasToken() {
      // 토큰 Refresh
      _ = APIService.memberProvider.rx.request(.login(id: email, pw: password))
        .asObservable()
        .retry()
        .bind { response in
          switch response.statusCode {
          case 200..<300:
            let responseModel = APIService.decode(ResponseModel<MemberDTO.Retrieve>.self, data: response.data).data
            TokenStorage.saveToken(token: responseModel.loginToken!)
          default:
            break
          }
        }
    }
  }
}
