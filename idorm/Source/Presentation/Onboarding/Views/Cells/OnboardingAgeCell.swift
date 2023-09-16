//
//  OnboardingAgeCell.swift
//  idorm
//
//  Created by 김응철 on 9/15/23.
//

import UIKit

import AEOTPTextField
import SnapKit
import RxSwift
import RxCocoa

final class OnboardingAgeCell: BaseCollectionViewCell {
  
  // MARK: - UI Components
  
  private lazy var textField: AEOTPTextField = {
    let textField = AEOTPTextField()
    textField.otpDefaultBorderColor = .iDormColor(.iDormGray200)
    textField.otpFilledBorderColor = .iDormColor(.iDormGray200)
    textField.otpBackgroundColor = .white
    textField.otpFilledBackgroundColor = .white
    textField.otpCornerRaduis = 10.0
    textField.otpFont = .iDormFont(.medium, size: 14.0)
    textField.otpTextColor = .iDormColor(.iDormGray400)
    textField.otpFilledBorderWidth = 1.0
    textField.otpDefaultBorderWidth = 1.0
    textField.otpDelegate = self
    textField.configure(with: 2)
    textField.clearOTP()
    return textField
  }()
  
  /// `세`가 적혀있는 `UILabel`
  private let label: UILabel = {
    let label = UILabel()
    label.text = "세"
    label.textColor = .iDormColor(.iDormGray300)
    label.font = .iDormFont(.medium, size: 12.0)
    return label
  }()
  
  // MARK: - Properties
  
  var ageTextFieldHandler: ((OnboardingSectionItem) -> Void)?
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.textField,
      self.label
    ].forEach {
      self.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.textField.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.directionalVerticalEdges.leading.equalToSuperview()
      make.width.equalTo(90.0)
    }
    
    self.label.snp.makeConstraints { make in
      make.centerY.equalTo(self.textField)
      make.leading.equalTo(self.textField.snp.trailing).offset(8.0)
    }
  }
}

// MARK: - AEOTPTextFieldDelegate

extension OnboardingAgeCell: AEOTPTextFieldDelegate {
  func didUserFinishEnter(the code: String) {
    self.ageTextFieldHandler?(.age(code))
  }
}
