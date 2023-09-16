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

final class TermsOfServiceViewController: BaseViewController, View {
  
  typealias Reactor = TermsOfServiceViewReactor
  
  // MARK: - UI Components
  
  /// 개인정보 처리방침 필수동의 `UIButton`
  private let termsOfServiceButton: iDormButton = {
    let button = iDormButton("개인정보 처리방침 필수동의", image: .iDormIcon(.deselect))
    button.baseBackgroundColor = .white
    button.baseForegroundColor = .iDormColor(.iDormGray400)
    button.imagePlacement = .leading
    button.imagePadding = 14.0
    button.contentInset = .zero
    let handelr: UIButton.ConfigurationUpdateHandler = { button in
      guard let button = button as? iDormButton else { return }
      switch button.state {
      case .selected:
        button.image = .iDormIcon(.select)
      default:
        button.image = .iDormIcon(.deselect)
      }
    }
    return button
  }()
  
  /// 보기 `UILabel`
  private let viewLabel: UILabel = {
    let label = UILabel()
    label.text = "보기"
    label.textColor = .iDormColor(.iDormGray200)
    label.font = .iDormFont(.medium, size: 12.0)
    return label
  }()
  
  /// 완료 `UIButton`
  private let continueButton: iDormButton = {
    let button = iDormButton("회원가입", image: nil)
    button.baseBackgroundColor = .iDormColor(.iDormBlue)
    button.baseForegroundColor = .white
    button.cornerRadius = 10.0
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
      make.bottom.equalToSuperview().inset(20.0)
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: TermsOfServiceViewReactor) {

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
    
    reactor.pulse(\.$navigateToCompleteSignUpVC)
      .skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.dismiss(animated: true) {
          let viewController = CompleteSignUpViewController()
          let reactor = CompleteSignupViewReactor()
          viewController.reactor = reactor
          owner.navigationController?.pushViewController(viewController, animated: true)
        }
      }
      .disposed(by: self.disposeBag)
  }
}

extension TermsOfServiceViewController: PanModalPresentable {
  var panScrollable: UIScrollView? { nil }
  var longFormHeight: PanModalHeight { .contentHeight(158.0) }
  var shortFormHeight: PanModalHeight { .contentHeight(158.0) }
  var cornerRadius: CGFloat { 24.0 }
}
