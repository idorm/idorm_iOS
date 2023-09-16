//
//  OnboardingTextFieldCell.swift
//  idorm
//
//  Created by 김응철 on 9/14/23.
//

import UIKit

import SnapKit

final class OnboardingTextFieldCell: BaseCollectionViewCell {
  
  // MARK: - UI Components
  
  /// 메인이 되는 `UITextField`
  private let textField: NewiDormTextField = {
    let textField = NewiDormTextField(type: .withBorderLine)
    textField.placeHolder = "입력"
    textField.placeHolderColor = .iDormColor(.iDormGray400)
    textField.textColor = .black
    textField.leftPadding = 16.0
    return textField
  }()
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()}
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.contentView.addSubview(self.textField)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.textField.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
    }
  }
  
  // MARK: - Configure
}
