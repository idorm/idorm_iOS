//
//  LaunchViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/30.
//

import UIKit
import OSLog

import SnapKit
import Then
import RxSwift
import RxCocoa
import RxMoya
import Firebase
import FirebaseMessaging

final class LaunchViewController: BaseViewController {
  
  // MARK: - Properties
  
  /// 화면 정중앙에 위치하는 로고 이미지입니다.
  private let idormImageView = UIImageView(image: UIImage(named: "idorm_white"))
  
  /// FCM토큰을 저장합니다.
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
          self?.requestLogin()
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
  
  // MARK: - Privates
  
  /// 로그인 화면으로 이동합니다.
  private func loginVC() {
    let loginVC = LoginViewController()
    loginVC.reactor = LoginViewReactor()
    let navVC = UINavigationController(rootViewController: loginVC)
    navVC.modalPresentationStyle = .fullScreen
    present(navVC, animated: false)
  }
  
  /// 메인 화면으로 이동합니다.
  private func mainVC() {
    let mainVC = TabBarViewController()
    mainVC.modalPresentationStyle = .fullScreen
    present(mainVC, animated: false)
  }
  
  /// 저장된 정보로 로그인을 시도합니다.
  private func requestLogin() {
    let email = UserStorage.shared.email
    let password = UserStorage.shared.password
    
    MemberAPI.provider.rx.request(.login(email: email, password: password, fcmToken: fcmToken!))
      .asObservable()
      .bind(with: self) { owner, response in
        do {
          let response = try response.filterSuccessfulStatusCodes()
          os_log(.info, "🔓 로그인에 성공하였습니다. 이메일: \(email), 비밀번호: \(password)")
          let token = response.response?.headers["authorization"]
          let member = NetworkUtility.decode(
            ResponseModel<MemberResponseModel.Member>.self,
            data: response.data
          ).data
          UserStorage.shared.saveMember(member)
          UserStorage.shared.saveToken(token)
          owner.retrieveMatchingInfoAPI()
        } catch (let error) {
          os_log(.error, "🔐 로그인에 실패하였습니다. 이메일: \(email), 비밀번호: \(password), 실패요인: \(error.localizedDescription)")
          owner.loginVC()
        }
      }
      .disposed(by: self.disposeBag)
  }
  
  /// 현재 저장된 매칭 정보를 가져옵니다.
  private func retrieveMatchingInfoAPI() {
    MatchingInfoAPI.provider.rx.request(.retrieve)
      .asObservable()
      .bind(with: self) { owner, response in
        do {
          let response = try response.filterSuccessfulStatusCodes()
          let matchingInfo = NetworkUtility.decode(
            ResponseModel<MatchingInfoResponseModel.MatchingInfo>.self,
            data: response.data
          ).data
          UserStorage.shared.saveMatchingInfo(matchingInfo)
          os_log(.info, "🟢 최초 회원의 매칭정보 조회를 성공했습니다.")
          owner.mainVC()
        } catch (let error) {
          os_log(.error, "❌ 최초 회원의 매칭정보 조회를 실패했습니다. 실패요인: \(error.localizedDescription)")
          owner.loginVC()
        }
      }
      .disposed(by: self.disposeBag)
  }
}
