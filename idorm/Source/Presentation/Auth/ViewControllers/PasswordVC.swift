//
//  PasswordViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/23.
//

import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa
import RxGesture
import ReactorKit

final class PasswordViewController: BaseViewController, View {
  
  typealias Reactor = PasswordViewReactor
  
  // MARK: - UI Components
  
  /// 비밀번호가 적혀있는 `UILabel`
  private let passwordLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.text = "비밀번호"
    label.font = .iDormFont(.medium, size: 14.0)
    return label
  }()
  
  /// 비밀번호 확인이 적혀있는 `UILabel`
  private let verifyPasswordLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.text = "비밀번호 확인"
    label.font = .iDormFont(.medium, size: 14.0)
    return label
  }()
  
  /// 비밀번호를 작성하는 `UITextField`
  private let passwordTextField: NewiDormTextField = {
    let textField = NewiDormTextField(type: .withBorderLine)
    textField.validationType = .password
    textField.isSecureTextEntry = true 
    textField.placeHolder = "비밀번호를 입력해주세요."
    return textField
  }()
  
  /// 비밀번호 확인을 작성하는 `UITextField`
  private let verifyPasswordTextField: NewiDormTextField = {
    let textField = NewiDormTextField(type: .withBorderLine)
    textField.placeHolder = "비밀번호를 한번 더 입력해주세요."
    textField.isSecureTextEntry = true
    return textField
  }()
  
  /// 비밀번호 글자수에 대한 `UILabel`
  private let passwordCountConditionLabel: UILabel = {
    let label = UILabel()
    label.textColor = .iDormColor(.iDormGray400)
    label.font = .iDormFont(.medium, size: 12.0)
    label.text = "•  8자 이상 입력"
    return label
  }()
  
  /// 비밀번호 조합에 대한 `UILabel`
  private let passwordCompoundConditonLabel: UILabel = {
    let label = UILabel()
    label.textColor = .iDormColor(.iDormGray400)
    label.font = .iDormFont(.medium, size: 12.0)
    label.text = "•  영문 소문자/숫자/특수 문자 조합"
    return label
  }()
  
  /// 계속하기 `UIButton`
  private let continueButton: iDormButton = {
    let button = iDormButton("계속하기", image: nil)
    button.baseBackgroundColor = .iDormColor(.iDormBlue)
    button.baseForegroundColor = .white
    button.cornerRadius = 10.0
    return button
  }()
  
  // MARK: - Bind
  
  func bind(reactor: PasswordViewReactor) {
    
    // Action
    
    self.passwordTextField.rx.text
      .map { Reactor.Action.passwordTextFieldDidChange($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.verifyPasswordTextField.rx.text
      .map { Reactor.Action.verifyPasswordTextFieldDidChange($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.passwordTextField.editingDidEnd
      .map { Reactor.Action.passwordTextFieldEditingDidEnd }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.verifyPasswordTextField.editingDidEnd
      .map { Reactor.Action.verifyPasswordTextFieldEditingDidEnd }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.continueButton.rx.tap
      .map { Reactor.Action.continueButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    
    reactor.state.map { $0.isValidatedToTextCount }
      .filter { $0 }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.passwordCountConditionLabel.textColor = .iDormColor(.iDormBlue)
      }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.isValidatedToCompoundCondition }
      .filter { $0 }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.passwordCompoundConditonLabel.textColor = .iDormColor(.iDormBlue)
      }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.isSameAsPassword }.skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, isSame in
        owner.verifyPasswordLabel.text =
        isSame ? "비밀번호 확인" : "두 비밀번호가 일치하지 않습니다. 다시 확인해주세요."
        owner.verifyPasswordLabel.textColor = isSame ? .black : .iDormColor(.iDormRed)
        owner.verifyPasswordTextField.borderColor =
        isSame ? .iDormColor(.iDormGray400) : .iDormColor(.iDormRed)
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$validationStates)
      .compactMap { $0 }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, states in
        owner.passwordLabel.textColor = .black
        owner.passwordCompoundConditonLabel.textColor = .iDormColor(.iDormGray400)
        owner.passwordCountConditionLabel.textColor = .iDormColor(.iDormGray400)
        if states.count && states.compound { // 조건을 모두 만족
        } else if states.count { // 글자수 조건만 만족
          owner.passwordLabel.textColor = .iDormColor(.iDormRed)
          owner.passwordCompoundConditonLabel.textColor = .iDormColor(.iDormRed)
        } else if states.compound { // 글자 조합 조건만 만족
          owner.passwordLabel.textColor = .iDormColor(.iDormRed)
          owner.passwordCountConditionLabel.textColor = .iDormColor(.iDormRed)
        } else { // 모두 불만족
          owner.passwordLabel.textColor = .iDormColor(.iDormRed)
          owner.passwordCompoundConditonLabel.textColor = .iDormColor(.iDormRed)
          owner.passwordCountConditionLabel.textColor = .iDormColor(.iDormRed)
        }
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$navigateToRootVC).skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.navigationController?.popToRootViewController(animated: true)
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$navigateToNicknameVC).skip(1)
      .debug()
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        let viewController = NicknameViewController()
        viewController.reactor = NicknameViewReactor(.signUp)
        owner.navigationController?.pushViewController(viewController, animated: true)
      }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.viewType }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, viewType in
        switch viewType {
        case .findPassword, .changePassword:
          owner.continueButton.title = "변경 완료"
          owner.navigationItem.title = "비밀번호 변경"
        case .signUp:
          owner.continueButton.title = "계속하기"
          owner.navigationItem.title = "회원가입"
        }
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.passwordTextField,
      self.verifyPasswordTextField,
      self.passwordLabel,
      self.verifyPasswordLabel,
      self.passwordCountConditionLabel,
      self.passwordCompoundConditonLabel,
      self.continueButton
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.passwordLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24.0)
      make.top.equalTo(self.view.safeAreaLayoutGuide).inset(33.0)
    }
    
    self.passwordTextField.snp.makeConstraints { make in
      make.top.equalTo(self.passwordLabel.snp.bottom).offset(8.0)
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
    }
    
    self.passwordCountConditionLabel.snp.makeConstraints { make in
      make.top.equalTo(self.passwordTextField.snp.bottom).offset(8.0)
      make.leading.equalToSuperview().inset(24.0)
    }
    
    self.passwordCompoundConditonLabel.snp.makeConstraints { make in
      make.top.equalTo(self.passwordCountConditionLabel.snp.bottom)
      make.leading.equalToSuperview().inset(24.0)
    }
    
    self.verifyPasswordLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24.0)
      make.top.equalTo(self.passwordCompoundConditonLabel.snp.bottom).offset(30.0)
    }
    
    self.verifyPasswordTextField.snp.makeConstraints { make in
      make.top.equalTo(self.verifyPasswordLabel.snp.bottom).offset(8.0)
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
    }
    
    self.continueButton.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
      make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-20.0)
    }
  }
  
  // MARK: - Functions
  
  
}
