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

final class LaunchViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let idormImageView = UIImageView(image: UIImage(named: "idorm_white"))
  
  // MARK: - LifeCycle
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if TokenStorage.hasToken() {
      requestAPI()
    } else {
      loginVC()
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
    let email = UserStorage.loadEmail()
    let password = UserStorage.loadPassword()

    APIService.memberProvider.rx.request(.login(id: email, pw: password))
      .asObservable()
      .retry()
      .withUnretained(self)
      .bind { owner, response in
        switch response.statusCode {
        case 200..<300:
          let responseData = APIService.decode(ResponseModel<MemberDTO.Retrieve>.self, data: response.data).data
          TokenStorage.saveToken(token: responseData.loginToken!)
          MemberStorage.shared.saveMember(responseData)
          owner.retrieveMatchingInfoAPI()
        default:
          owner.loginVC()
        }
      }
      .disposed(by: disposeBag)
  }
  
  private func retrieveMatchingInfoAPI() {
    APIService.onboardingProvider.rx.request(.retrieve)
      .asObservable()
      .retry()
      .withUnretained(self)
      .bind { owner, response in
        switch response.statusCode {
        case 200:
          let responseData = APIService.decode(ResponseModel<MatchingInfoDTO.Retrieve>.self, data: response.data).data
          MemberStorage.shared.saveMatchingInfo(responseData)
          owner.mainVC()
        case 204:
          owner.mainVC()
        default:
          owner.loginVC()
        }
      }
      .disposed(by: disposeBag)
  }
}