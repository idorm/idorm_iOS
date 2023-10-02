//
//  TermsOfServiceViewController.swift
//  idorm
//
//  Created by 김응철 on 2023/01/02.
//

import UIKit

import SnapKit
import Then
import PanModal
import RxSwift
import RxCocoa
import RxGesture
import ReactorKit

final class AuthTermsOfServiceViewController: BaseViewController, View {
  
  typealias Reactor = AuthTermsOfServiceViewReactor
  
  // MARK: - UI Components
  
  /// 개인정보 처리방침 필수동의 `UIButton`
  private let termsOfServiceButton: iDormButton = {
    let button = iDormButton("개인정보 처리방침 필수동의", image: .iDormIcon(.deselect))
    button.baseBackgroundColor = .white
    button.baseForegroundColor = .iDormColor(.iDormGray400)
    button.imagePlacement = .leading
    button.imagePadding = 14.0
    button.contentInset = .zero
    button.font = .iDormFont(.medium, size: 14.0)
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      guard let button = button as? iDormButton else { return }
      switch button.state {
      case .selected:
        button.image = .iDormIcon(.select)
      default:
        button.image = .iDormIcon(.deselect)
      }
    }
    button.configurationUpdateHandler = handler
    return button
  }()
  
  /// 보기 `UILabel`
  private let viewLabel: UILabel = {
    let label = UILabel()
    label.text = "보기"
    label.textColor = .iDormColor(.iDormGray200)
    label.font = .iDormFont(.medium, size: 14.0)
    return label
  }()
  
  /// 완료 `UIButton`
  private let continueButton: iDormButton = {
    let button = iDormButton("회원가입", image: nil)
    button.baseBackgroundColor = .iDormColor(.iDormBlue)
    button.baseForegroundColor = .white
    button.cornerRadius = 10.0
    button.font = .iDormFont(.medium, size: 14.0)
    return button
  }()
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.termsOfServiceButton,
      self.viewLabel,
      self.continueButton
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.termsOfServiceButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24.0)
      make.top.equalToSuperview().inset(37.0)
    }
    
    self.viewLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.termsOfServiceButton.snp.trailing).offset(8.0)
      make.centerY.equalTo(self.termsOfServiceButton)
    }
    
    self.continueButton.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide)
      make.height.equalTo(53.0)
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: AuthTermsOfServiceViewReactor) {

    // Action
    
    self.termsOfServiceButton.rx.tap
      .map { Reactor.Action.termsOfServiceButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.continueButton.rx.tap
      .map { Reactor.Action.continueButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.viewLabel.rx.tapGesture().when(.recognized)
      .map { _ in Reactor.Action.viewLabelDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    
    reactor.pulse(\.$isSelectedTermsOfServiceButton)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, isSelected in
        owner.termsOfServiceButton.isSelected = isSelected
        owner.continueButton.isEnabled = isSelected
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$navigateToCompleteSignUpVC).skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        guard
          let presentingVC = owner.presentingViewController as? UINavigationController
        else { return }
        owner.dismiss(animated: true) {
          let viewController = AuthCompleteSignUpViewController()
          let reactor = AuthCompleteSignupViewReactor()
          viewController.reactor = reactor
          presentingVC.pushViewController(viewController, animated: true)
        }
      }
      .disposed(by: self.disposeBag)
  }
}

extension AuthTermsOfServiceViewController: PanModalPresentable {
  var panScrollable: UIScrollView? { nil }
  var longFormHeight: PanModalHeight { .contentHeight(158.0) }
  var shortFormHeight: PanModalHeight { .contentHeight(158.0) }
  var cornerRadius: CGFloat { 24.0 }
}
