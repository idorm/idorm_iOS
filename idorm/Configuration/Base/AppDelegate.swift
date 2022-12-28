//
//  AppDelegate.swift
//  idorm
//
//  Created by 김응철 on 2022/12/20.
//

import UIKit

import RxSwift
import RxCocoa

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    setupNavigationBarAppearance()
    setupTabBarAppearance()
    setupMemberStorage()
    
    Thread.sleep(forTimeInterval: 1)
    
    return true
  }
}

extension AppDelegate {
  private func setupNavigationBarAppearance() {
    let appearance = AppearanceManager.navigationAppearance(from: .white, shadow: false)
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
  
  private func setupMemberStorage() {
    let email = UserStorage.loadEmail()
    let password = UserStorage.loadPassword()
    
    _ = APIService.memberProvider.rx.request(.login(id: email, pw: password))
      .asObservable()
      .retry()
      .map(ResponseModel<MemberDTO.Retrieve>.self)
      .bind { response in
        TokenStorage.saveToken(token: response.data.loginToken!)
        MemberStorage.shared.saveMember(response.data)
      }
    
    _ = APIService.onboardingProvider.rx.request(.retrieve)
      .asObservable()
      .retry()
      .map(ResponseModel<MatchingInfoDTO.Retrieve>.self)
      .bind {
        MemberStorage.shared.saveMatchingInfo($0.data)
      }
  }
}
