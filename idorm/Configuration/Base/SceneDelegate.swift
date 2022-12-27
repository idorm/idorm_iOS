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
      
      let email = UserStorage.loadEmail()
      let password = UserStorage.loadPassword()
      _ = APIService.memberProvider.rx.request(.login(id: email, pw: password))
        .asObservable()
        .retry()
        .map(ResponseModel<MemberDTO.Retrieve>.self)
        .withUnretained(self)
        .bind { owner, response in
          TokenStorage.saveToken(token: response.data.loginToken!)
          MemberStorage.shared.saveMember(response.data)
        }
      
      window?.rootViewController = TabBarViewController()
    } else {
      let loginVC = LoginViewController()
      loginVC.reactor = LoginViewReactor()
      window?.rootViewController = UINavigationController(rootViewController: loginVC)
    }
    
    window?.makeKeyAndVisible()
  }
}

