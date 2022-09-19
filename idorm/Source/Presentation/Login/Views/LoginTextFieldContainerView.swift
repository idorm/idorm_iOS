//
//  LoginTextFieldContainerView.swift
//  idorm
//
//  Created by 김응철 on 2022/07/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

// 쓰인적 없는 Component
class LoginTextFieldContainerView: UIView {
  // MARK: - Properties
  let placeholder: String
  
  var disposeBag = DisposeBag()
  
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
    button.addTarget(self, action: #selector(didTapXmarkButton), for: .touchUpInside)
    button.isHidden = true
    
    return button
  }()
  
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
  @objc private func didTapXmarkButton() {
    textField.text = ""
    xmarkButton.isHidden = true
    textField.becomeFirstResponder()
  }
  
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
      .map{ $0.count <= 20 }
      .asSignal(onErrorJustReturn: false)
      .emit(onNext: { [weak self] isEditable in
        if !isEditable {
          self?.textField.text = String(self?.textField.text?.dropLast() ?? "")
        }
      })
      .disposed(by: disposeBag)
  }
}
