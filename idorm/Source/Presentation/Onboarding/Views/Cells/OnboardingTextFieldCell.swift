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
  private lazy var textField: NewiDormTextField = {
    let textField = NewiDormTextField(type: .withBorderLine)
    textField.placeHolder = "입력"
    textField.placeHolderColor = .iDormColor(.iDormGray400)
    textField.textColor = .black
    textField.leftPadding = 16.0
    textField.isOnboarding = true
    textField.textField.addTarget(
      self,
      action: #selector(self.textFieldDidChange(_:)),
      for: .valueChanged
    )
    return textField
  }()
  
  // MARK: - Properties
  
  private var isReused: Bool = false
  private var item: OnboardingSectionItem?
  var textFieldHandler: ((OnboardingSectionItem) -> Void)?
  
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
  
  // MARK: - Selectors
  
  @objc
  private func textFieldDidChange(_ textField: UITextField) {
    guard let text = textField.text else { return }
    let item: OnboardingSectionItem
    switch self.item {
    case .wakeUpTime:
      item = .wakeUpTime(text)
    case .arrangement:
      item = .arrangement(text)
    case .showerTime:
      item = .showerTime(text)
    case .kakao:
      item = .kakao(text)
    case .mbti:
      item = .mbti(text)
    default:
      fatalError("잘못된 OnboardingSectionItem이 Cell에 주입되었습니다.")
    }
    self.textFieldHandler?(item)
  }
  
  // MARK: - Configure
  
  func configure(with item: OnboardingSectionItem) {
    guard !self.isReused else { return }
    self.item = item
    self.isReused = true
    switch item {
    case.wakeUpTime(let text),
        .arrangement(let text),
        .showerTime(let text),
        .kakao(let text),
        .mbti(let text):
      self.textField.text = text
      
    default: break
    }
  }
}
