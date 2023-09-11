//
//  AuthNumberViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/24.
//

import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit

/// 인증번호를 입력하는 페이지입니다.
final class AuthNumberViewController: BaseViewController, View {
  
  typealias Reactor = AuthNumberViewReactor
  
  // MARK: - UI Components
   
  /// 메일함에서 인증번호를 확인해주세요. 가 적혀있는 `UILabel`
  private let shouldCheckMailBoxLabel: UILabel = {
    let label = UILabel()
    label.text = "메일함에서 인증번호를 확인해주세요."
    label.font = .iDormFont(.medium, size: 12.0)
    label.textColor = .iDormColor(.iDormGray400)
    return label
  }()
  
  /// 인증번호 재요청 `iDormButton`
  private let requestAuthNumberButton: iDormButton = {
    let button = iDormButton("인증번호 재요청", image: nil)
    button.baseBackgroundColor = .white
    button.baseForegroundColor = .iDormColor(.iDormGray300)
    button.font = .iDormFont(.medium, size: 12.0)
    button.contentInset = .zero
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      guard let button = button as? iDormButton else { return }
      switch button.state {
      case .disabled:
        button.baseForegroundColor = .iDormColor(.iDormGray300)
      default:
        button.baseForegroundColor = .iDormColor(.iDormBlue)
      }
    }
    button.configurationUpdateHandler = handler
    return button
  }()
  
  /// 00:00 과 같이 시간을 알려주는 타이머 역할의 `UILabel`
  private let timerLabel: UILabel = {
    let label = UILabel()
    label.textColor = .iDormColor(.iDormBlue)
    label.font = .iDormFont(.medium, size: 14.0)
    return label
  }()
  
  /// 인증번호를 입력하는 `UITextField`
  private let textField: NewiDormTextField = {
    let textField = NewiDormTextField(type: .withBorderLine)
    textField.placeHolder = "인증번호를 입력해주세요."
    return textField
  }()
  
  /// 계속하기 `UIButton`
  private let continueButton: iDormButton = {
    let button = iDormButton("계속하기", image: nil)
    button.baseBackgroundColor = .iDormColor(.iDormBlue)
    button.baseForegroundColor = .white
    return button
  }()

  // MARK: - Bind
  
  func bind(reactor: AuthNumberViewReactor) {
    
    // Action
    
    self.textField.textObservable
      .map { Reactor.Action.textFieldDidChange($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.continueButton.rx.tap
      .map { Reactor.Action.continueButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.requestAuthNumberButton.rx.tap
      .map { Reactor.Action.requestAuthNumberButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    
    reactor.pulse(\.$shouldDismiss)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        let emailVC = Logger.shared.emailVC!
        owner.dismiss(animated: true) {
          let authProcess = Logger.shared.authProcess
          let reactor: PasswordViewReactor
          let passwordVC = PasswordViewController()
          switch authProcess {
          case .signUp:
            reactor = .init(.signUp)
          case .findPw:
            reactor = .init(.findPassword)
          }
          passwordVC.reactor = reactor
          emailVC.navigationController?.pushViewController(passwordVC, animated: true)
        }
      }
      .disposed(by: self.disposeBag)
    
    MailStopWatchManager.shared.isFinished
      .distinctUntilChanged()
      .filter { $0 }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        AlertManager.shared.showAlertPopup("인증번호가 만료되었습니다.")
      }
      .disposed(by: self.disposeBag)
    
    MailStopWatchManager.shared.remainingTime
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, remainingTime in
        owner.textField.text = remainingTime
        if remainingTime != nil {
          // 시간이 만료되었을 때
          owner.textField.baseBackgroundColor = .iDormColor(.iDormGray200)
          owner.textField.isEnabled = false
          owner.requestAuthNumberButton.isEnabled = true
        } else {
          // 시간이 흐를 때
          owner.textField.baseBackgroundColor = .white
          owner.textField.isEnabled = true
          owner.requestAuthNumberButton.isEnabled = false
        }
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.navigationItem.title = "인증번호 입력"
    self.view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    super.setupLayouts()
      
    [
      self.shouldCheckMailBoxLabel,
      self.requestAuthNumberButton,
      self.textField,
      self.timerLabel,
      self.continueButton
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.shouldCheckMailBoxLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(self.view.safeAreaLayoutGuide).inset(50)
    }
    
    self.requestAuthNumberButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(20)
      make.centerY.equalTo(self.shouldCheckMailBoxLabel)
    }
    
    self.textField.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(24)
      make.top.equalTo(self.shouldCheckMailBoxLabel.snp.bottom).offset(14)
    }
    
    self.continueButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top).offset(-20)
    }
    
    self.timerLabel.snp.makeConstraints { make in
      make.trailing.equalTo(self.textField.snp.trailing).offset(-14)
      make.centerY.equalTo(textField)
    }
  }
  
  // MARK: - Functions
  
  override func touchesBegan(
    _ touches: Set<UITouch>,
    with event: UIEvent?
  ) {
    self.view.endEditing(true)
  }
}
