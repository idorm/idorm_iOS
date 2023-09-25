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
    textField.textField.delegate = self
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

// MARK: - Privates

private extension MatchingInfoSetupTextFieldCell {
  /// 클립보드에 있는 텍스트를 URL형식의 String으로 변환해주는 메서드입니다.
  func extractLinkFromText(_ text: String) -> String? {
    let pattern = "(?i)https?://(?:www\\.)?\\S+(?:/|\\b)"
    guard let regex = try? NSRegularExpression(
      pattern: pattern,
      options: []
    ) else {
      return nil
    }
    
    if let result = regex.firstMatch(
      in: text,
      options: [],
      range: NSRange(location: 0, length: text.utf16.count)
    ) {
      let url = (text as NSString).substring(with: result.range)
      return url
    }
    return nil
  }
}

extension MatchingInfoSetupTextFieldCell: UITextFieldDelegate {
  func textField(
    _ textField: UITextField,
    shouldChangeCharactersIn range: NSRange,
    replacementString string: String
  ) -> Bool {
    guard self.item == .kakao else { return true }
    if let clipboardText = UIPasteboard.general.string {
      if let url = self.extractLinkFromText(clipboardText) {
        self.textField.rx.text.onNext(url)
        return false
      }
      return true
    }
    return true
  }
}
