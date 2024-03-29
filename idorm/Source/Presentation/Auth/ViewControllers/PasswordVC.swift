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
import ReactorKit

final class PasswordViewController: BaseViewController, View {
  
  // MARK: - PROPERTIES
  
  private let infoLabel = UILabel().then {
    $0.text = "비밀번호"
    $0.textColor = .black
    $0.font = .iDormFont(.medium, size: 14)
  }
  
  private let infoLabel2 = UILabel().then {
    $0.text = "비밀번호 확인"
    $0.textColor = .black
    $0.font = .iDormFont(.medium, size: 14)
  }
  
  private let textCountConditionLabel = UILabel().then {
    $0.text = "•  8자 이상 입력"
    $0.textColor = .idorm_gray_400
    $0.font = .iDormFont(.medium, size: 12)
  }
  
  private let compoundConditionLabel = UILabel().then {
    $0.text = "•  영문 소문자/숫자/특수 문자 조합"
    $0.textColor = .idorm_gray_400
    $0.font = .iDormFont(.medium, size: 12)
  }
  
  private let indicator = UIActivityIndicatorView().then { $0.color = .darkGray }
  
  private let textField1 = PasswordTextField(placeholder: "비밀번호를 입력해주세요.")
  private let textField2 = PasswordTextField(placeholder: "비밀번호를 한번 더 입력해주세요.")
  private var confirmButton: OldiDormButton!
  private let type: AuthProcess
  
  // MARK: - LifeCycle
  
  init(_ type: AuthProcess) {
    self.type = type
    super.init(nibName: nil, bundle: nil)
    setupComponents()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Bind
  
  func bind(reactor: PasswordViewReactor) {
    
    // MARK: - Action
    
    // 텍스트필드1 변화 감지
    textField1.textField.rx.text
      .orEmpty
      .map { PasswordViewReactor.Action.didChangeTextField1($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 텍스트필드2 변화 감지
    textField2.textField.rx.text
      .orEmpty
      .map { PasswordViewReactor.Action.didChangeTextField2($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // Tf1 포커싱 이벤트
    textField1.textField.rx.controlEvent(.editingDidBegin)
      .map { PasswordViewReactor.Action.editingDidBeginTf1 }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // Tf2 포커싱 이벤트
    textField2.textField.rx.controlEvent(.editingDidBegin)
      .map { PasswordViewReactor.Action.editingDidBeginTf2 }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // Tf1 포커싱 해제
    textField1.textField.rx.controlEvent(.editingDidEnd)
      .map { PasswordViewReactor.Action.editingDidEndTf1 }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // Tf2 포커싱 해제
    textField2.textField.rx.controlEvent(.editingDidEnd)
      .map { PasswordViewReactor.Action.editingDidEndTf2 }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 계속하기 버튼
    confirmButton.rx.tap
      .map { PasswordViewReactor.Action.didTapConfirmButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // MARK: - State
    
    // Tf1 BorderColor
    reactor.state
      .map { $0.currentBorderColorTf1 }
      .map { $0.cgColor }
      .distinctUntilChanged()
      .bind(to: textField1.layer.rx.borderColor)
      .disposed(by: disposeBag)
    
    // Tf2 BorderColor
    reactor.state
      .map { $0.currentBorderColorTf2 }
      .map { $0.cgColor }
      .distinctUntilChanged()
      .bind(to: textField2.layer.rx.borderColor)
      .disposed(by: disposeBag)
    
    // CompoundLabel Color
    reactor.state
      .map { $0.currentCompoundLabelColor }
      .distinctUntilChanged()
      .bind(to: compoundConditionLabel.rx.textColor)
      .disposed(by: disposeBag)
    
    // CountLabel Color
    reactor.state
      .map { $0.currentCountLabelColor }
      .distinctUntilChanged()
      .bind(to: textCountConditionLabel.rx.textColor)
      .disposed(by: disposeBag)
    
    // InfoLabel Color
    reactor.state
      .map { $0.currentInfoLabelTextColor }
      .distinctUntilChanged()
      .bind(to: infoLabel.rx.textColor)
      .disposed(by: disposeBag)
    
    // InfoLabel2 Color
    reactor.state
      .map { $0.currentInfoLabel2TextColor }
      .distinctUntilChanged()
      .bind(to: infoLabel2.rx.textColor)
      .disposed(by: disposeBag)
    
    // InfoLabel2 Text
    reactor.state
      .map { $0.currentInfoLabel2Text }
      .bind(to: infoLabel2.rx.text)
      .disposed(by: disposeBag)
    
    // Tf1 Checkmark
    reactor.state
      .map { $0.isHiddenTf1Checkmark }
      .distinctUntilChanged()
      .bind(to: textField1.checkmarkButton.rx.isHidden)
      .disposed(by: disposeBag)
    
    // Tf2 Checkmark
    reactor.state
      .map { $0.isHiddenTf2Checkmark }
      .distinctUntilChanged()
      .bind(to: textField2.checkmarkButton.rx.isHidden)
      .disposed(by: disposeBag)
    
    // 오류 팝업
    reactor.state
      .map { $0.isOpenedPopup }
      .filter { $0.0 }
      .withUnretained(self)
      .bind { owner, message in
        let popup = iDormPopupViewController(contents: message.1)
        popup.modalPresentationStyle = .overFullScreen
        owner.present(popup, animated: false)
      }
      .disposed(by: disposeBag)
    
    // NicknameVC로 이동
    reactor.state
      .map { $0.isOpenedNicknameVC }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let nicknameVC = NicknameViewController(.signUp)
        nicknameVC.reactor = NicknameViewReactor(.signUp)
        owner.navigationController?.pushViewController(nicknameVC, animated: true)
      }
      .disposed(by: disposeBag)
    
    // LoginVC로 이동
    reactor.state
      .map { $0.isOpenedLoginVC }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let loginVC = LoginViewController()
        loginVC.reactor = LoginViewReactor()
        let navVC = UINavigationController(rootViewController: loginVC)
        SceneUtils.switchRootVC(to: navVC, animated: true)
      }
      .disposed(by: disposeBag)
    
    // 뒤로가기
    reactor.state
      .map { $0.popVC }
      .filter { $0 }
      .withUnretained(self)
      .bind { $0.0.navigationController?.popViewController(animated: true) }
      .disposed(by: disposeBag)
    
    // 인디케이터 애니메이션
    reactor.state
      .map { $0.isLoading }
      .distinctUntilChanged()
      .bind(to: indicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    // 화면 인터렉션 제어
    reactor.state
      .map { $0.isLoading }
      .map { !$0 }
      .bind(to: view.rx.isUserInteractionEnabled)
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  private func setupComponents() {
    switch type {
    case .signUp:
      self.confirmButton = OldiDormButton("계속하기")
    case .findPw:
      self.confirmButton = OldiDormButton("변경 완료")
    }
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [
      infoLabel,
      infoLabel2,
      textField1,
      textField2,
      confirmButton,
      textCountConditionLabel,
      compoundConditionLabel,
      indicator
    ]
      .forEach { view.addSubview($0) }
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .white
    
    switch type {
    case .signUp:
      navigationItem.title = "회원가입"
    case .findPw:
      navigationItem.title = "비밀번호 변경"
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    infoLabel.snp.makeConstraints { make in
      make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(24)
    }
    
    textField1.snp.makeConstraints { make in
      make.top.equalTo(infoLabel.snp.bottom).offset(8)
      make.leading.trailing.equalToSuperview().inset(24)
      make.height.equalTo(50)
    }
    
    textCountConditionLabel.snp.makeConstraints { make in
      make.top.equalTo(textField1.snp.bottom).offset(8)
      make.leading.equalToSuperview().inset(24)
    }
    
    compoundConditionLabel.snp.makeConstraints { make in
      make.top.equalTo(textCountConditionLabel.snp.bottom)
      make.leading.equalToSuperview().inset(24)
    }
    
    infoLabel2.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(textCountConditionLabel.snp.bottom).offset(30)
    }
    
    textField2.snp.makeConstraints { make in
      make.top.equalTo(infoLabel2.snp.bottom).offset(8)
      make.trailing.leading.equalToSuperview().inset(24)
      make.height.equalTo(50)
    }
    
    confirmButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-20)
      make.height.equalTo(50)
    }
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }

  // MARK: - Helpers
  
  override func touchesBegan(
    _ touches: Set<UITouch>,
    with event: UIEvent?
  ) {
    view.endEditing(true)
  }
}
