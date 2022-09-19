//
//  LoginPasswordTextFieldContainerView.swift
//  idorm
//
//  Created by 김응철 on 2022/07/16.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class RegisterPwTextField: UIView {
  // MARK: - Properties
  lazy var textField: UITextField = {
    let tf = UITextField()
    tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
      NSAttributedString.Key.foregroundColor: UIColor.idorm_gray_300,
      NSAttributedString.Key.font: UIFont.init(name: MyFonts.medium.rawValue, size: 14.0) ?? 0
    ])
    tf.textColor = .idorm_gray_300
    tf.font = .init(name: MyFonts.medium.rawValue, size: 14.0)
    tf.addLeftPadding(16)
    tf.backgroundColor = .white
    tf.keyboardType = .default
    tf.returnKeyType = .done
    tf.isSecureTextEntry = true
    
    return tf
  }()
  
  lazy var openEyesButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "OpenEyes"), for: .normal)
    button.isHidden = true
    
    return button
  }()
  
  lazy var closeEyesButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "CloseEyes"), for: .normal)
    button.isHidden = true
    
    return button
  }()
  
  lazy var checkmarkButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "Checkmark"), for: .normal)
    button.isHidden = true
    
    return button
  }()
  
  let placeholder: String
  let disposeBag = DisposeBag()
  
  // MARK: - LifeCycle
  init(placeholder: String) {
    self.placeholder = placeholder
    super.init(frame: .zero)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Bind
  func bind() {
    openEyesButton.rx.tap
      .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        self?.textField.isSecureTextEntry = false
        self?.openEyesButton.isHidden = true
        self?.closeEyesButton.isHidden = false
      })
      .disposed(by: disposeBag)
    
    closeEyesButton.rx.tap
      .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        self?.textField.isSecureTextEntry = true
        self?.openEyesButton.isHidden = false
        self?.closeEyesButton.isHidden = true
      })
      .disposed(by: disposeBag)
    
    textField.rx.controlEvent(.editingDidBegin)
      .asDriver()
      .drive(onNext: { [weak self] in
        self?.layer.borderColor = UIColor.idorm_blue.cgColor
        self?.openEyesButton.isHidden = false
        self?.checkmarkButton.isHidden = true
      })
      .disposed(by: disposeBag)
    
    textField.rx.controlEvent(.editingDidEnd)
      .asDriver()
      .drive(onNext: { [weak self] in
        self?.openEyesButton.isHidden = true
        self?.closeEyesButton.isHidden = true
        let text = self?.textField.text
        
        if LoginUtilities.isValidPasswordFinal(pwd: text ?? "") {
          self?.checkmarkButton.isHidden = false
          self?.layer.borderColor = UIColor.idorm_gray_400.cgColor
        } else {
          self?.checkmarkButton.isHidden = true
        }

      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  private func configureUI() {
    [ textField, openEyesButton, closeEyesButton, checkmarkButton ]
      .forEach { addSubview($0) }
    
    backgroundColor = .white
    layer.borderWidth = 1
    layer.cornerRadius = 10
    layer.borderColor = UIColor.idorm_gray_400.cgColor
    
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
