//
//  PutEmailViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/21.
//

import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class AuthEmailViewController: BaseViewController, View {
  
  typealias Reactor = AuthEmailViewReactor
  
  // MARK: - UI Components
  
  /// 텍스트 필드에 어떤 것을 입력해야할지 알려주는 `UILabel`
  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.medium, size: 14.0)
    label.textColor = .iDormColor(.iDormGray400)
    return label
  }()
  
  /// 이메일 `iDormTextField`
  private let emailTextField: iDormTextField = {
    let textField = iDormTextField(type: .withBorderLine)
    textField.placeHolder = "이메일을 입력해주세요."
    textField.keyboardType = .emailAddress
    return textField
  }()
  
  /// 인천대학교 이메일 (@inu.ac.kr) 이 필요해요.가 적혀있는 `iDormButton`
  private let emailDescriptionButton: iDormButton = {
    let button = iDormButton("인천대학교 이메일 (@inu.ac.kr) 이 필요해요.", image: .iDormIcon(.inu))
    button.imagePadding = 6.0
    button.font = .iDormFont(.regular, size: 12.0)
    button.baseForegroundColor = .iDormColor(.iDormGray400)
    button.baseBackgroundColor = .white
    button.edgeInsets = .zero
    button.isUserInteractionEnabled = false
    button.isHidden = true
    return button
  }()
  
  /// 계속하기 `iDormButton`
  private let continueButton: iDormButton = {
    let button = iDormButton("계속하기", image: nil)
    button.baseBackgroundColor = .iDormColor(.iDormBlue)
    button.baseForegroundColor = .white
    button.cornerRadius = 10.0
    button.font = .iDormFont(.medium, size: 14.0)
    return button
  }()
  
  // MARK: - Bind
  
  func bind(reactor: AuthEmailViewReactor) {
    
    // Action

    self.emailTextField.rx.text
      .map { Reactor.Action.emailTextFieldDidChange($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.continueButton.rx.tap
      .map { Reactor.Action.continueButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    
    reactor.state.map { $0.viewType }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, viewType in
        switch viewType {
        case .signUp:
          owner.navigationItem.title = "회원가입"
          owner.descriptionLabel.text = "이메일"
          owner.emailDescriptionButton.isHidden = false
        case .changePassword:
          owner.navigationItem.title = "비밀번호 변경"
          owner.descriptionLabel.text = "가입시 사용한 인천대학교 이메일이 필요해요."
        case .findPassword:
          owner.navigationItem.title = "비밀번호 찾기"
          owner.descriptionLabel.text = "가입시 사용한 인천대학교 이메일이 필요해요."
        }
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$shouldPresentToAuthVC)
      .filter { $0 }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        let viewController = AuthViewController()
        viewController.reactor = AuthViewReactor()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        owner.present(navigationController, animated: true)
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.descriptionLabel,
      self.emailTextField,
      self.emailDescriptionButton,
      self.continueButton
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    self.view.backgroundColor = .white
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.descriptionLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24.0)
      make.top.equalTo(self.view.safeAreaLayoutGuide).inset(50.0)
    }
    
    self.emailTextField.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
      make.top.equalTo(self.descriptionLabel.snp.bottom).offset(8.0)
    }
    
    self.emailDescriptionButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.emailTextField.snp.bottom).offset(10.0)
    }
    
    self.continueButton.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
      make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top).offset(-16.0)
      make.height.equalTo(53.0)
    }
  }
  
  // MARK: - Helpers
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}
