//
//  OnboardingTextViewCell.swift
//  
//
//  Created by 김응철 on 9/16/23.
//

import UIKit

import SnapKit
import RSKGrowingTextView

final class OnboardingTextViewCell: BaseCollectionViewCell {
  
  // MARK: - UI Components
  
  /// 메인이 되는 `UITextView`
  private lazy var textView: RSKGrowingTextView = {
    let textView = RSKGrowingTextView()
    textView.attributedPlaceholder = NSAttributedString(
      string: "입력",
      attributes: [
        NSAttributedString.Key.font: UIFont.iDormFont(.regular, size: 14),
        NSAttributedString.Key.foregroundColor: UIColor.iDormColor(.iDormGray300)]
    )
    textView.font = .iDormFont(.regular, size: 14)
    textView.layer.borderColor = UIColor.iDormColor(.iDormGray300).cgColor
    textView.textColor = .black
    textView.layer.cornerRadius = 10
    textView.layer.borderWidth = 1
    textView.isScrollEnabled = false
    textView.keyboardType = .default
    textView.returnKeyType = .done
    textView.backgroundColor = .clear
    textView.textContainerInset = UIEdgeInsets(top: 15, left: 9, bottom: 15, right: 9)
    textView.animateHeightChange = false
    textView.growingTextViewDelegate = self
    return textView
  }()
  
  /// 제약조건을 도와주는 `UIView`
  private let supportView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    return view
  }()
  
  // MARK: - Properties
  
  private var heightConstraint: Constraint?
  var textViewHandler: ((OnboardingSectionItem) -> Void)?
  
  // MARK: - Setup
  
  override func setupLayouts() {
    [
      self.supportView,
      self.textView
    ].forEach {
      self.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.textView.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
    }
    
    self.supportView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      self.heightConstraint = make.height.equalTo(53.0).constraint
    }
  }
  
  // MARK: - Configure
  
  func configure(with text: String) {
    self.textView.text = text
  }
}

extension OnboardingTextViewCell: RSKGrowingTextViewDelegate {
  func growingTextView(
    _ textView: RSKGrowingTextView,
    didChangeHeightFrom growingTextViewHeightBegin: CGFloat,
    to growingTextViewHeightEnd: CGFloat
  ) {
    print(growingTextViewHeightEnd)
    self.heightConstraint?.update(offset: growingTextViewHeightEnd)
  }
  
  func textViewDidChange(_ textView: UITextView) {
    self.textViewHandler?(.wantToSay(textView.text))
  }
}
