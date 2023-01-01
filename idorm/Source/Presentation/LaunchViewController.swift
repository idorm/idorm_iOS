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
      .map(ResponseModel<MemberDTO.Retrieve>.self)
      .withUnretained(self)
      .bind { owner, response in
        TokenStorage.saveToken(token: response.data.loginToken!)
        MemberStorage.shared.saveMember(response.data)
        owner.retrieveMatchingInfoAPI()
      }
      .disposed(by: disposeBag)
  }
  
  private func retrieveMatchingInfoAPI() {
    APIService.onboardingProvider.rx.request(.retrieve)
      .asObservable()
      .retry()
      .map(ResponseModel<MatchingInfoDTO.Retrieve>.self)
      .withUnretained(self)
      .bind { owner, response in
        MemberStorage.shared.saveMatchingInfo(response.data)
        owner.mainVC()
      }
      .disposed(by: disposeBag)
  }
}
