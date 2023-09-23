//
//  OnboardingTextFieldCell.swift
//  idorm
//
//  Created by 김응철 on 9/14/23.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class MatchingInfoSetupTextFieldCell: BaseCollectionViewCell {
  
  // MARK: - UI Components
  
  /// 메인이 되는 `UITextField`
  private lazy var textField: NewiDormTextField = {
    let textField = NewiDormTextField(type: .withBorderLine)
    textField.placeHolder = "입력"
    textField.placeHolderColor = .iDormColor(.iDormGray400)
    textField.textColor = .black
    textField.leftPadding = 16.0
    textField.isOnboarding = true
    return textField
  }()
  
  // MARK: - Properties
  
  private var item: MatchingInfoSetupSectionItem?
  var textFieldHandler: ((MatchingInfoSetupSectionItem, String) -> Void)?
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
  }
  
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
  
  // MARK: - Bind
  
  override func bind() {
    self.textField.rx.text
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, text in
        guard let item = owner.item else { return }
        if item == .mbti &&
           text.count > 4 {
          let truncatedText = String(text.prefix(4))
          owner.textField.rx.text.onNext(truncatedText)
          owner.textFieldHandler?(item, truncatedText)
          return
        }
        owner.textFieldHandler?(item, text)
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Configure
  
  func configure(item: MatchingInfoSetupSectionItem, text: String) {
    if text.isEmpty {
      self.textField.isHiddenCheckCircleImageView = true
    } else {
      self.textField.isHiddenCheckCircleImageView = false
    }
    self.item = item
    self.textField.rx.text.onNext(text)
  }
}
