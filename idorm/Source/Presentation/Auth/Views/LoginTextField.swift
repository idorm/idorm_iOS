//
//  LoginTextField.swift
//  idorm
//
//  Created by 김응철 on 2022/12/21.
//

import UIKit

import SnapKit

final class LoginTextField: UITextField {
  
  // MARK: - PROPERTIES
  
  private let customPlaceholder: String
  
  // MARK: - INITIALIZER
  
  init(_ placeholder: String) {
    self.customPlaceholder = placeholder
    super.init(frame: .zero)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - SETUP

extension LoginTextField: BaseView {
  func setupStyles() {
    self.attributedPlaceholder = NSAttributedString(
      string: customPlaceholder,
      attributes: [
        .foregroundColor: UIColor.idorm_gray_300,
        .font: UIFont.init(name: IdormFont_deprecated.medium.rawValue, size: 14) ?? 0
      ]
    )
    self.textColor = .idorm_gray_300
    self.backgroundColor = .idorm_gray_100
    self.font = .init(name: IdormFont_deprecated.medium.rawValue, size: 14)
    self.layer.cornerRadius = 14.0
    self.addLeftPadding(16)
  }
  
  func setupLayouts() {}
  
  func setupConstraints() {
    self.snp.makeConstraints { make in
      make.height.equalTo(54)
    }
  }
}
