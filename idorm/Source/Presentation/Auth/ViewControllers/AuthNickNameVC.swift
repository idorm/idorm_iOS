//
//  NicknameViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/25.
//

import UIKit

import SnapKit
import Then
import PanModal
import RxSwift
import RxCocoa
import ReactorKit

final class AuthNicknameViewController: BaseViewController, View {
  
  typealias Reactor = AuthNicknameViewReactor
  
  // MARK: - UI Components

  /// idorm 프로필 닉네임을 입력해주세요. 가 적혀있는 `UILabel`
  private let enterNicknameLabel: UILabel = {
    let label = UILabel()
    label.text = "idorm 프로필 닉네임 입력해주세요."
    label.textColor = .iDormColor(.iDormGray400)
    label.font = .iDormFont(.regular, size: 16.0)
    return label
  }()

  /// 그림자가 들어간 하얀색 백그라운드 `UIView`
  private let backgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    return view
  }()
  
  /// 최대 글자 수를 나타내는 `UILabel`
  private let textLengthLabel: UILabel = {
    let label = UILabel()
    label.text = " / 8 pt"
    label.textColor = .iDormColor(.iDormGray300)
    label.font = .iDormFont(.medium, size: 14.0)
    return label
  }()

  /// 현재 글자 수를 나타내는 `UILabel`
  private let currentLengthLabel: UILabel = {
    let label = UILabel()
    label.text = "0"
    label.textColor = .iDormColor(.iDormBlue)
    label.font = .iDormFont(.medium, size: 14.0)
    return label
  }()
  
  /// 글자 수 조건을 나타내는 `UILabel`
  private let countConditionLabel: UILabel = {
    let label = UILabel()
    label.text = "•  최소 2글자에서 8글자를 입력해주세요."
    label.textColor = .iDormColor(.iDormGray400)
    label.font = .iDormFont(.medium, size: 12.0)
    return label
  }()
  
  /// 공백 조건을 나타내는 `UILabel`
  private let spacingConditionLabel: UILabel = {
    let label = UILabel()
    label.text = "•  공백없이 입력해주세요."
    label.textColor = .iDormColor(.iDormGray400)
    label.font = .iDormFont(.medium, size: 12.0)
    return label
  }()

  /// 조합 조건을 나타내는 `UILabel`
  private let compoundConditionLabel: UILabel = {
    let label = UILabel()
    label.text = "•  영문, 한글, 숫자만 입력할 수 있어요."
    label.textColor = .idorm_gray_400
    label.font = .iDormFont(.medium, size: 12)
    return label
  }()
  
  /// 조건 레이블을 모아둔 `UIStackView`
  private lazy var conditionStackView: UIStackView = {
    let stackView = UIStackView()
    [
      self.countConditionLabel,
      self.spacingConditionLabel,
      self.compoundConditionLabel
    ].forEach {
      stackView.addArrangedSubview($0)
    }
    stackView.axis = .vertical
    return stackView
  }()
  
  /// 계속하기 `UIButton`
  private let continueButton: iDormButton = {
    let button = iDormButton("계속하기", image: nil)
    button.baseBackgroundColor = .iDormColor(.iDormBlue)
    button.baseForegroundColor = .white
    button.cornerRadius = 10.0
    return button
  }()
  
  /// 닉네임을 입력할 수 있는 `UITextField`
  private let textField: iDormTextField = {
    let textField = iDormTextField(type: .withBorderLine)
    textField.placeHolder = "닉네임"
    return textField
  }()
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.view.backgroundColor = .iDormColor(.iDormGray100)
    self.navigationItem.title = "닉네임"
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.view.addSubview(self.backgroundView)
    [
      self.enterNicknameLabel,
      self.currentLengthLabel,
      self.textLengthLabel,
      self.textField,
      self.conditionStackView,
      self.continueButton
    ].forEach {
      self.backgroundView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.backgroundView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview()
      make.top.equalTo(self.view.safeAreaLayoutGuide).inset(24)
      make.height.equalTo(320.0)
    }
    
    self.enterNicknameLabel.snp.makeConstraints { make in
      make.top.leading.equalToSuperview().inset(24.0)
    }
    
    self.textLengthLabel.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(24.0)
      make.top.equalTo(self.enterNicknameLabel.snp.bottom).offset(24.0)
    }
    
    self.currentLengthLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.textLengthLabel)
      make.trailing.equalTo(self.textLengthLabel.snp.leading)
    }
    
    self.textField.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
      make.top.equalTo(self.currentLengthLabel.snp.bottom).offset(8.0)
    }
    
    self.conditionStackView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24.0)
      make.top.equalTo(self.textField.snp.bottom).offset(8.0)
    }
    
    self.continueButton.snp.makeConstraints { make in
      make.bottom.directionalHorizontalEdges.equalToSuperview().inset(24)
      make.height.equalTo(53.0)
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: AuthNicknameViewReactor) {
    
    // Action
    
    self.textField.rx.text
      .map { Reactor.Action.textFieldDidChange($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.textField.editingDidEnd
      .map { Reactor.Action.textFieldEditingDidEnd }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.continueButton.rx.tap
      .map { Reactor.Action.continueButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    
    reactor.state.map { $0.viewType }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, viewType in
        switch viewType {
        case .changeNickname:
          owner.continueButton.title = "변경하기"
        case .signUp:
          owner.continueButton.title = "계속하기"
        }
      }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.nickname.count }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, count in
        owner.currentLengthLabel.text = "\(count)"
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$isValidatedAllConditions).skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, isValidated in
        owner.textField.borderColor =
        isValidated ? .iDormColor(.iDormGray300) : .iDormColor(.iDormRed)
      }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.isValidatedCountCondition }.skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, isValidated in
        owner.countConditionLabel.textColor =
        isValidated ? .iDormColor(.iDormBlue) : .iDormColor(.iDormRed)
      }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.isValidatedSpacingCondition }.skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, isValidated in
        owner.spacingConditionLabel.textColor =
        isValidated ? .iDormColor(.iDormBlue) : .iDormColor(.iDormRed)
      }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.isValidatedCompoundCondition }.skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, isValidated in
        owner.compoundConditionLabel.textColor =
        isValidated ? .iDormColor(.iDormBlue) : .iDormColor(.iDormRed)
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$isPopping).skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.navigationController?.popViewController(animated: true)
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$presentToTermsOfServiceVC).skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        let bottomSheet = AuthTermsOfServiceViewController()
        bottomSheet.reactor = AuthTermsOfServiceViewReactor()
        owner.presentPanModal(bottomSheet)
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Helpers
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}
