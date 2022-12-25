//
//  NicknameViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/25.
//

import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit

final class NicknameViewController: BaseViewController, View {
  
  typealias Reactor = NicknameViewReactor
  
  // MARK: - Properties
  
  private let mainLabel = UILabel().then {
    $0.text = "idorm 프로필 닉네임을 입력해주세요."
    $0.textColor = .idorm_gray_400
    $0.font = .init(name: MyFonts.regular.rawValue, size: 16)
  }
  
  private let backgroundView = UIView().then {
    $0.backgroundColor = .white
  }
  
  private let maxLengthLabel = UILabel().then {
    $0.text = "/ 8 pt"
    $0.textColor = .idorm_gray_300
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14)
  }
  
  private let currentLenghtLabel = UILabel().then {
    $0.text = "0"
    $0.textColor = .idorm_blue
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14)
  }
  
  private let indicator = UIActivityIndicatorView().then {
    $0.color = .gray
  }
  
  private let countConditionLabel = UILabel().then {
    $0.text = "•  최소 2글자에서 8글자를 입력해주세요."
    $0.textColor = .idorm_gray_400
    $0.font = .init(name: MyFonts.medium.rawValue, size: 12)
  }
  
  private let spacingConditionLabel = UILabel().then {
    $0.text = "•  공백없이 입력해주세요."
    $0.textColor = .idorm_gray_400
    $0.font = .init(name: MyFonts.medium.rawValue, size: 12)
  }

  private let compoundConditionLabel = UILabel().then {
    $0.text = "•  영문, 한글, 숫자만 입력할 수 있어요."
    $0.textColor = .idorm_gray_400
    $0.font = .init(name: MyFonts.medium.rawValue, size: 12)
  }
  
  private lazy var ConditionStackView = UIStackView().then { stack in
    [countConditionLabel, spacingConditionLabel, compoundConditionLabel]
      .forEach { stack.addArrangedSubview($0) }
    stack.axis = .vertical
  }
  
  private let textField = idormTextField("변경할 닉네임을 입력해주세요.")
  private let confirmButton = idormButton("완료")
  
  private let type: RegisterEnumerations.Nickname
  private let reactor: NicknameViewReactor
  
  // MARK: - LifeCycle
  
  init(_ type: RegisterEnumerations.Nickname) {
    self.type = type
    self.reactor = NicknameViewReactor(type)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Bind
  
  func bind(reactor: NicknameViewReactor) {
    
    // MARK: - Action
    
    textField.rx.text
      .orEmpty
      .scan("") { $1.count > 8 ? $0 : $1 }
      .bind(to: textField.rx.text)
      .disposed(by: disposeBag)
    
    // 텍스트 반응
    textField.rx.text
      .orEmpty
      .map { NicknameViewReactor.Action.didChangeTextField($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 텍스트필드 포커싱
    textField.rx.controlEvent(.editingDidBegin)
      .map { NicknameViewReactor.Action.editingDidBeginTf }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 텍스트필드 포커싱 해제
    textField.rx.controlEvent(.editingDidEnd)
      .map { NicknameViewReactor.Action.editingDidEndTf }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 완료 버튼
    confirmButton.rx.tap
      .map { NicknameViewReactor.Action.didTapConfirmButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // MARK: - State
    
    // BorderColor Tf
    reactor.state
      .map { $0.currentBorderColorTf }
      .distinctUntilChanged()
      .map { $0.cgColor }
      .bind(to: textField.layer.rx.borderColor)
      .disposed(by: disposeBag)
    
    // CountLabel TextColor
    reactor.state
      .map { $0.currentCountLabelTextColor }
      .distinctUntilChanged()
      .bind(to: countConditionLabel.rx.textColor)
      .disposed(by: disposeBag)
    
    // Compound TextColor
    reactor.state
      .map { $0.currentCompoundLabelTextColor }
      .distinctUntilChanged()
      .bind(to: compoundConditionLabel.rx.textColor)
      .disposed(by: disposeBag)
    
    // Spacing TextColor
    reactor.state
      .map { $0.currentSpacingLabelTextColor }
      .distinctUntilChanged()
      .bind(to: spacingConditionLabel.rx.textColor)
      .disposed(by: disposeBag)
    
    // 체크마크 표시
    reactor.state
      .map { $0.isHiddenCheckmark }
      .bind(to: textField.checkmarkButton.rx.isHidden)
      .disposed(by: disposeBag)
    
    // 현재 글자수
    reactor.state
      .map { String($0.currentTextCount) }
      .bind(to: currentLenghtLabel.rx.text)
      .disposed(by: disposeBag)
    
    // 오류 팝업
    reactor.state
      .map { $0.isOpenedPopup }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let popup = BasicPopup(contents: "조건을 다시 확인해주세요.")
        popup.modalPresentationStyle = .overFullScreen
        owner.present(popup, animated: false)
      }
      .disposed(by: disposeBag)
    
    // 로딩 중
    reactor.state
      .map { $0.isLoading }
      .distinctUntilChanged()
      .bind(to: indicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    // CompleteSignupVC 이동
    reactor.state
      .map { $0.isOpenedCompleteSignupVC }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let completeSignupVC = CompleteSignUpViewController()
        completeSignupVC.modalPresentationStyle = .fullScreen
        owner.present(completeSignupVC, animated: true)
      }
      .disposed(by: disposeBag)
    
    // PopVC
    reactor.state
      .map { $0.popVC }
      .filter { $0 }
      .withUnretained(self)
      .bind { $0.0.navigationController?.popViewController(animated: true) }
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    view.backgroundColor = .idorm_gray_100
    navigationItem.title = "닉네임"
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    view.addSubview(backgroundView)
    [
      mainLabel,
      maxLengthLabel,
      textField,
      confirmButton,
      currentLenghtLabel,
      ConditionStackView,
      indicator
    ]
      .forEach { backgroundView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    backgroundView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(view.safeAreaLayoutGuide).inset(24)
      make.height.equalTo(320)
    }
    
    mainLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(view.safeAreaLayoutGuide).inset(48)
    }
    
    maxLengthLabel.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(24)
      make.top.equalTo(mainLabel.snp.bottom).offset(24)
    }
    
    textField.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(maxLengthLabel.snp.bottom).offset(8)
      make.height.equalTo(50)
    }
    
    confirmButton.snp.makeConstraints { make in
      make.bottom.leading.trailing.equalToSuperview().inset(24)
      make.height.equalTo(52)
    }
    
    currentLenghtLabel.snp.makeConstraints { make in
      make.centerY.equalTo(maxLengthLabel)
      make.trailing.equalTo(maxLengthLabel.snp.leading).offset(-4)
    }
    
    ConditionStackView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(textField.snp.bottom).offset(8)
    }
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  // MARK: - Helpers
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}
