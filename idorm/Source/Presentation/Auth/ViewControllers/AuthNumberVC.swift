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

final class AuthNumberViewController: BaseViewController, View {
  
  typealias Reactor = AuthNumberViewReactor
  
  // MARK: - Properties
  
  private let infoLabel = UILabel().then {
    $0.text = "지금 이메일로 인증번호를 보내드렸어요!"
    $0.textColor = .darkGray
    $0.font = .init(name: MyFonts.medium.rawValue, size: 12.0)
  }
  
  private let authOnemoreButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    config.baseForegroundColor = .idorm_blue
    var container = AttributeContainer()
    container.font = .init(name: MyFonts.medium.rawValue, size: 12)
    config.attributedTitle = AttributedString("인증번호 재요청", attributes: container)
    
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .disabled:
        button.configuration?.baseForegroundColor = .idorm_gray_300
      default:
        button.configuration?.baseForegroundColor = .idorm_blue
      }
    }
    
    $0.configurationUpdateHandler = handler
    $0.configuration = config
    $0.isEnabled = false
  }
  
  private let timerLabel = UILabel().then {
    $0.text = "05:00"
    $0.textColor = .idorm_blue
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14.0)
  }
  
  private let indicator = UIActivityIndicatorView().then {
    $0.color = .gray
  }
  
  private let confirmButton = idormButton("인증 완료")
  private let textField = idormTextField("인증번호를 입력해주세요.")

  private let reactor: AuthNumberViewReactor
  private let mailTimer: MailTimerChecker
  
  // MARK: - LifeCycle
  
  init(_ timer: MailTimerChecker) {
    self.mailTimer = timer
    self.reactor = AuthNumberViewReactor(timer)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Bind
  
  func bind(reactor: AuthNumberViewReactor) {
    
    // MARK: - Action
    
    // 인증 완료 버튼
    confirmButton.rx.tap
      .withUnretained(self)
      .map { $0.0.textField.text ?? "" }
      .map { AuthNumberViewReactor.Action.didTapConfirmButton($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 인증번호 재요청 버튼
    authOnemoreButton.rx.tap
      .map { AuthNumberViewReactor.Action.didTapRequestAuthButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // MARK: - State
    
    // 인디케이터 제어
    reactor.state
      .map { $0.isLoading }
      .bind(to: indicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    // 오류 팝업
    reactor.state
      .map { $0.isOpenedPopup }
      .filter { $0.0 }
      .withUnretained(self)
      .bind { owner, contents in
        let popup = BasicPopup(contents: contents.1)
        popup.modalPresentationStyle = .overFullScreen
        owner.present(popup, animated: false)
      }
      .disposed(by: disposeBag)
    
    // TODO: ConfirmPwVC 화면전환 구현
    // 창 닫기 -> 인증완료
    reactor.state
      .map { $0.popVC }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        guard let authVC = owner.presentingViewController else { return }
        guard let putEmailVC = authVC.presentingViewController else { return }
        
//        let confirmPwVC: ConfirmPasswordViewController
//        switch Logger.shared.type {
//        case .signUp:
//        case .findPw, .modifyPw:
//
//        }
        
        owner.dismiss(animated: true) {
          authVC.dismiss(animated: true)
          // TODO: 화면전환 구현
        }
      }
      .disposed(by: disposeBag)
    
    // 남은 시간 경과
    mailTimer.isPassed
      .distinctUntilChanged()
      .withUnretained(self)
      .bind { owner, isPassed in
        if isPassed {
          owner.textField.backgroundColor = .idorm_gray_200
          owner.textField.isEnabled = false
          owner.authOnemoreButton.isEnabled = true
          let popup = BasicPopup(contents: "인증번호가 만료되었습니다.")
          popup.modalPresentationStyle = .overFullScreen
          owner.present(popup, animated: false)
        } else {
          owner.textField.backgroundColor = .white
          owner.textField.isEnabled = true
          owner.authOnemoreButton.isEnabled = false
        }
      }
      .disposed(by: disposeBag)
    
    // 남은 시간 감지
    mailTimer.leftTime
      .filter { $0 >= 0 }
      .withUnretained(self)
      .bind { owner, elapseTime in
        let minutes = elapseTime / 60
        let seconds = elapseTime % 60
        let minutesString = String(format: "%02d", minutes)
        let secondsString = String(format: "%02d", seconds)
        owner.timerLabel.text = "\(minutesString):\(secondsString)"
      }
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    navigationItem.title = "인증번호 입력"
    view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    super.setupLayouts()
      
    [infoLabel, authOnemoreButton, textField, confirmButton, timerLabel, indicator]
      .forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    infoLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
    }
    
    authOnemoreButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(20)
      make.centerY.equalTo(infoLabel)
    }
    
    textField.snp.makeConstraints { make in
      make.trailing.leading.equalToSuperview().inset(24)
      make.top.equalTo(infoLabel.snp.bottom).offset(14)
      make.height.equalTo(50)
    }
    
    confirmButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-20)
      make.height.equalTo(50)
    }
    
    timerLabel.snp.makeConstraints { make in
      make.trailing.equalTo(textField.snp.trailing).offset(-14)
      make.centerY.equalTo(textField)
    }
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(50)
    }
  }
  
  // MARK: - Helpers
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}

