//
//  TextFieldContainerView.swift
//  idorm
//
//  Created by 김응철 on 2022/07/16.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class OnboardingTextField: UIView {
  // MARK: - Properties
  lazy var textField: UITextField = {
    let tf = UITextField()
    tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
      NSAttributedString.Key.foregroundColor: UIColor.idorm_gray_300,
      NSAttributedString.Key.font: UIFont.init(name: MyFonts.medium.rawValue, size: 14.0) ?? 0
    ])
    tf.textColor = .black
    tf.font = .init(name: MyFonts.medium.rawValue, size: 14.0)
    tf.addLeftPadding(16)
    tf.backgroundColor = .white
    tf.keyboardType = .default
    tf.returnKeyType = .done
    
    return tf
  }()
  
  lazy var checkmarkButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "Checkmark"), for: .normal)
    button.isHidden = true
    
    return button
  }()
  
  lazy var xmarkButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "Xmark_Grey"), for: .normal)
    button.isHidden = true
    
    return button
  }()
  
  let placeholder: String
  private var disposeBag = DisposeBag()
  
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
  
  // MARK: - Selectors
  
  // MARK: - Helpers
  private func configureUI() {
    [ textField, checkmarkButton, xmarkButton ]
      .forEach { addSubview($0) }
    
    backgroundColor = .white
    layer.borderWidth = 1
    layer.cornerRadius = 10
    layer.borderColor = UIColor.idorm_gray_300.cgColor
    
    textField.snp.makeConstraints { make in
      make.leading.bottom.top.equalToSuperview()
      make.trailing.equalToSuperview().inset(40)
    }
    
    checkmarkButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(8)
    }
    
    xmarkButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(8)
    }
  }

  private func bind() {
    textField.rx.text.orEmpty
      .scan("") { pervious, new -> String in
        if new.count >= 30 {
          return pervious
        } else {
          return new
        }
      }
      .asDriver(onErrorJustReturn: "")
      .drive(textField.rx.text)
      .disposed(by: disposeBag)
    
    textField.rx.controlEvent(.editingChanged)
      .asDriver()
      .drive(onNext: { [weak self] in
        self?.xmarkButton.isHidden = false
      })
      .disposed(by: disposeBag)
    
    textField.rx.controlEvent(.editingDidBegin)
      .asDriver()
      .drive(onNext: { [weak self] in
        self?.checkmarkButton.isHidden = true
        self?.layer.borderColor = UIColor.idorm_blue.cgColor
      })
      .disposed(by: disposeBag)
    
    textField.rx.controlEvent(.editingDidEnd)
      .asDriver()
      .drive(onNext: { [weak self] in
        let text = self?.textField.text ?? ""
        self?.layer.borderColor = UIColor.idorm_gray_300.cgColor
        self?.xmarkButton.isHidden = true
        if text.count >= 1 {
          self?.checkmarkButton.isHidden = false
        } else {
          self?.checkmarkButton.isHidden = true
        }
      })
      .disposed(by: disposeBag)
  }
}
