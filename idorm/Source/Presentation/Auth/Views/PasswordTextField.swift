//
//  PasswordTextField.swift
//  idorm
//
//  Created by 김응철 on 2022/12/23.
//

import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa

final class PasswordTextField: UIView {
  
  // MARK: - Properties
  
  lazy var textField = UITextField().then {
    $0.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
      NSAttributedString.Key.foregroundColor: UIColor.idorm_gray_300,
      NSAttributedString.Key.font: UIFont.init(name: IdormFont_deprecated.medium.rawValue, size: 14.0) ?? 0
    ])
    $0.textColor = .idorm_gray_300
    $0.font = .init(name: IdormFont_deprecated.medium.rawValue, size: 14.0)
    $0.addLeftPadding(16)
    $0.backgroundColor = .white
    $0.keyboardType = .default
    $0.returnKeyType = .done
    $0.isSecureTextEntry = true
  }
  
  let openEyesButton = UIButton().then {
    $0.setImage(UIImage(named: "eye_open"), for: .normal)
    $0.isHidden = true
  }
  
  let closeEyesButton = UIButton().then {
    $0.setImage(UIImage(named: "eye_close"), for: .normal)
    $0.isHidden = true
  }
  
  let checkmarkButton = UIButton().then {
    $0.setImage(UIImage(named: "circle_checkmark_blue"), for: .normal)
    $0.isHidden = true
    $0.isUserInteractionEnabled = false
  }
  
  private let placeholder: String
  private let disposeBag = DisposeBag()
  
  // MARK: - LifeCycle
  
  init(placeholder: String) {
    self.placeholder = placeholder
    super.init(frame: .zero)
    setupStyles()
    setupLayout()
    setupConstraints()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Bind
  
  private func bind() {
    
    // OpenEyesButton 클릭이벤트 -> 비밀번호 보이기
    openEyesButton.rx.tap
      .bind(onNext: { [weak self] in
        self?.textField.isSecureTextEntry = false
        self?.openEyesButton.isHidden = true
        self?.closeEyesButton.isHidden = false
      })
      .disposed(by: disposeBag)
    
    // CloseEyesButton 클릭이벤트 -> 비밀번호 숨기기
    closeEyesButton.rx.tap
      .bind(onNext: { [weak self] in
        self?.textField.isSecureTextEntry = true
        self?.openEyesButton.isHidden = false
        self?.closeEyesButton.isHidden = true
      })
      .disposed(by: disposeBag)
    
    textField.rx.controlEvent(.editingDidEnd)
      .map { true }
      .bind(to: openEyesButton.rx.isHidden)
      .disposed(by: disposeBag)
    
    textField.rx.controlEvent(.editingDidEnd)
      .map { true }
      .bind(to: closeEyesButton.rx.isHidden)
      .disposed(by: disposeBag)
    
    textField.rx.controlEvent(.editingDidBegin)
      .map { false }
      .bind(to: openEyesButton.rx.isHidden)
      .disposed(by: disposeBag)
    
    textField.rx.controlEvent(.editingDidBegin)
      .map { UIColor.idorm_blue.cgColor }
      .bind(to: layer.rx.borderColor)
      .disposed(by: disposeBag)
    
    textField.rx.controlEvent(.editingDidEnd)
      .map { UIColor.idorm_gray_400.cgColor }
      .bind(to: layer.rx.borderColor)
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  private func setupLayout() {
    [ textField, openEyesButton, closeEyesButton, checkmarkButton ]
      .forEach { addSubview($0) }
  }
  
  private func setupStyles() {
    backgroundColor = .white
    layer.borderWidth = 1
    layer.cornerRadius = 10
    layer.borderColor = UIColor.idorm_gray_400.cgColor
  }
  
  private func setupConstraints() {
    textField.snp.makeConstraints { make in
      make.leading.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(40)
    }
    
    openEyesButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(8)
    }
    
    closeEyesButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(8)
    }
    
    checkmarkButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(8)
    }
  }
}
