//
//  CompleteSignUpViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/25.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class AuthCompleteSignUpViewController: BaseViewController, View {
  
  typealias Reactor = AuthCompleteSignupViewReactor
  
  // MARK: - UI Components
  
  /// `안녕하세요 가입을 축하드려요.`가 적혀있는 `UILabel`
  private let celebrateLabel: UILabel = {
    let label = UILabel()
    label.textColor = .iDormColor(.iDormGray400)
    label.text = "안녕하세요! 가입을 축하드려요."
    label.textAlignment = .center
    label.font = .iDormFont(.bold, size: 18)
    return label
  }()
  
  /// 정보성 `UILabel`
  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.medium, size: 12)
    label.textColor = .iDormColor(.iDormGray300)
    label.textAlignment = .center
    label.numberOfLines = 0
    label.text = """
    로그인 후 인천대학교 기숙사 룸메이트 매칭을 위한
    기본정보를 알려주세요.
    """
    return label
  }()
  
  /// `로그인 후 계속하기`가 적혀있는 `UIButton`
  private let continueButton: iDormButton = {
    let button = iDormButton("로그인 후 계속하기", image: nil)
    button.baseBackgroundColor = .iDormColor(.iDormBlue)
    button.baseForegroundColor = .white
    button.contentInset = NSDirectionalEdgeInsets(
      top: 10.0, leading: 40.0, bottom: 10.0, trailing: 40.0
    )
    button.font = .iDormFont(.medium, size: 16.0)
    button.shadowOpacity = 0.11
    button.shadowRadius = 2.0
    button.shadowOffset = CGSize(width: 0, height: 2)
    return button
  }()
  
  /// `ic_domi`인 `UIImageView`
  private let domiImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .iDormIcon(.domi)
    return imageView
  }()
  
  // MARK: - LifeCycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  // MARK: - Bind
  
  func bind(reactor: AuthCompleteSignupViewReactor) {
    
    // Action
    
    self.continueButton.rx.tap
      .map { Reactor.Action.continueButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    
    reactor.pulse(\.$navigateToOnboardingVC).skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        let viewController = MatchingInfoSetupViewController()
        let reactor = MatchingInfoSetupViewReactor(.signUp)
        viewController.reactor = reactor
        owner.navigationController?.setViewControllers([viewController], animated: true)
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.domiImageView,
      self.celebrateLabel,
      self.descriptionLabel,
      self.continueButton
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.domiImageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalTo(self.view.safeAreaLayoutGuide).offset(-60.0)
    }
    
    self.celebrateLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.domiImageView.snp.bottom).offset(64.0)
    }

    self.descriptionLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.celebrateLabel.snp.bottom).offset(8.0)
    }
    
    self.continueButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.descriptionLabel.snp.bottom).offset(64.0)
      make.height.equalTo(44.0)
    }
  }
}
