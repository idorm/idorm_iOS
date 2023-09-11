//
//  AuthViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/23.
//

import UIKit

import SnapKit
import Then
import WebKit
import RxSwift
import RxCocoa
import ReactorKit

final class AuthViewController: BaseViewController, View {
  
  typealias Reactor = AuthViewReactor
  
  // MARK: - UI Components
  
  /// ic_cancel 인 `UIButton`
  private let cancelButton: iDormButton = {
    let button = iDormButton("", image: .iDormIcon(.cancel))
    return button
  }()
  
  /// ic_mailBox 인 `UIImageView`
  private let mailBoxImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .iDormIcon(.mailBox)
    return imageView
  }()
  
  /// 지금 이메일로 인증번호를 보내드렸어요.🕊가 쓰여있는 `UILabel`
  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.medium, size: 14.0)
    label.textColor = .iDormColor(.iDormGray300)
    label.textAlignment = .center
    label.text =
    """
    지금 이메일로 인증번호를 보내드렸어요.🕊
    메일이 오지 않았으면 스팸함을 확인해주세요.
    """
    return label
  }()
  
  /// 메일함 바로가기 `UIButton`
  private let goMailBoxButton: iDormButton = {
    let button = iDormButton("메일함 바로가기", image: nil)
    button.font = .iDormFont(.medium, size: 14.0)
    button.baseBackgroundColor = .white
    button.baseForegroundColor = .iDormColor(.iDormGray400)
    button.borderWidth = 1.0
    button.borderColor = .iDormColor(.iDormGray200)
    button.cornerRadius = 10.0
    return button
  }()
  
  /// 인증번호 입력 `UIButton`
  private let enterNumberButton: iDormButton = {
    let button = iDormButton("인증번호 입력", image: nil)
    button.baseBackgroundColor = .iDormColor(.iDormBlue)
    button.baseForegroundColor = .white
    button.cornerRadius = 10.0
    return button
  }()
  
  // MARK: - Bind
  
  func bind(reactor: AuthViewReactor) {
    
    // Action
    
    self.rx.viewDidLoad
      .map { Reactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)

    self.cancelButton.rx.tap
      .map { Reactor.Action.cancelButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.goMailBoxButton.rx.tap
      .map { Reactor.Action.goMailBoxButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.enterNumberButton.rx.tap
      .map { Reactor.Action.enterNumberButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    
    reactor.pulse(\.$shouldNavigateToAuthNumberVC)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, mailTimerChecker in
        let authNumberVC = AuthNumberViewController()
        authNumberVC.reactor = AuthNumberViewReactor()
        owner.navigationController?.pushViewController(authNumberVC, animated: true)
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$shouldDismiss)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in owner.dismiss(animated: true) }
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
      self.cancelButton,
      self.mailBoxImageView,
      self.descriptionLabel,
      self.goMailBoxButton,
      self.enterNumberButton
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.cancelButton.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide).inset(10.0)
      make.leading.equalToSuperview().inset(20.0)
    }
    
    self.mailBoxImageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.cancelButton.snp.bottom).offset(123.0)
    }
    
    self.descriptionLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.mailBoxImageView.snp.bottom).offset(20.0)
    }
    
    self.enterNumberButton.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(54.0)
    }
    
    self.goMailBoxButton.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
      make.bottom.equalTo(self.enterNumberButton.snp.top).offset(-8.0)
    }
  }
}
