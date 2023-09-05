//
//  iDormSplashViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/30.
//

import UIKit
import OSLog

import SnapKit
import Then
import ReactorKit
import RxSwift
import RxCocoa
import RxMoya
import Firebase
import FirebaseMessaging

final class iDormSplashViewController: BaseViewController, View {
  
  typealias Reactor = iDormSplashViewReactor
  
  // MARK: - UI Components
  
  /// 화면 정중앙에 위치하는 로고 이미지입니다.
  private let idormImageView = UIImageView(image: UIImage(named: "idorm_white"))
  
  // MARK: - Properties
  
  /// 이 화면의 `CompletionHandler`입니다.
  var dismissCompletion: (() -> Void)?
  
  // MARK: - LifeCycle
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    guard let reactor = self.reactor else { return }
    // FCMToken 요청을 보냅니다.
    FCMTokenManager.shared.requestFCMToken { token in
      reactor.action.onNext(.requestFCMToken(fcmToken: token))
    }
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupLayouts()
    self.view.backgroundColor = .iDormColor(.iDormBlue)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    self.view.addSubview(self.idormImageView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    self.idormImageView.snp.makeConstraints { make in
      make.center.equalTo(self.view.safeAreaLayoutGuide)
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: iDormSplashViewReactor) {
    // Action
    
    // State
    reactor.pulse(\.$shouldNavgiateToLoginVC)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        let viewController = LoginViewController()
        let reactor = LoginViewReactor()
        viewController.reactor = reactor
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        owner.present(navigationController, animated: false)
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$shouldNavigateToTabBarVC)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        let viewController = TabBarViewController()
        viewController.modalPresentationStyle = .fullScreen
        owner.present(viewController, animated: false)
        owner.dismissCompletion?()
      }
      .disposed(by: self.disposeBag)
  }
}
