//
//  LaunchViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/30.
//

import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa
import RxMoya
import Firebase
import FirebaseMessaging

final class LaunchViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let idormImageView = UIImageView(image: UIImage(named: "idorm_white"))
  var fcmToken: String?
  
  // MARK: - LifeCycle
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    Messaging.messaging().token { [weak self] token, error in
      if let error = error {
        print("Error fetching FCM registration token: \(error)")
      }
      else if let token = token {
        self?.fcmToken = token
        if UserStorage.shared.token != "" {
          self?.requestAPI()
        } else {
          self?.loginVC()
        }
      }
    }
    
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    view.backgroundColor = .idorm_blue
  }
  
  override func setupLayouts() {
    view.addSubview(idormImageView)
  }
  
  override func setupConstraints() {
    idormImageView.snp.makeConstraints { make in
      make.center.equalTo(view.safeAreaLayoutGuide)
    }
  }
    
  // MARK: - Helpers
  
  private func loginVC() {
    let loginVC = LoginViewController()
    loginVC.reactor = LoginViewReactor()
    let navVC = UINavigationController(rootViewController: loginVC)
    navVC.modalPresentationStyle = .fullScreen
    present(navVC, animated: false)
  }
  
  private func mainVC() {
    let mainVC = TabBarViewController()
    mainVC.modalPresentationStyle = .fullScreen
    present(mainVC, animated: false)
  }
  
  private func requestAPI() {
    let email = UserStorage.shared.email
    let password = UserStorage.shared.password
    MemberAPI.provider.rx.request(
      .login(email: email, password: password, fcmToken: fcmToken!)
    )
      .asObservable()
      .retry()
      .withUnretained(self)
      .bind { owner, response in
        switch response.statusCode {
        case 200..<300:
          let token = response.response?.headers["authorization"]
          let member = MemberAPI.decode(
            ResponseModel<MemberResponseModel.Member>.self,
            data: response.data).data
          UserStorage.shared.saveMember(member)
          UserStorage.shared.saveToken(token)
          owner.retrieveMatchingInfoAPI()
        default:
          owner.loginVC()
        }
      }
      .disposed(by: disposeBag)
  }
  
  private func retrieveMatchingInfoAPI() {
    MatchingInfoAPI.provider.rx.request(.retrieve)
      .asObservable()
      .retry()
      .withUnretained(self)
      .bind { owner, response in
        switch response.statusCode {
        case 200:
          let matchingInfo = MatchingInfoAPI.decode(
            ResponseModel<MatchingInfoResponseModel.MatchingInfo>.self,
            data: response.data
          ).data
          UserStorage.shared.saveMatchingInfo(matchingInfo)
          owner.mainVC()
        case 404:
          owner.mainVC()
        default:
          owner.loginVC()
        }
      }
      .disposed(by: disposeBag)
  }
}
