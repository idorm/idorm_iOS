//
//  OnboardingTextViewCell.swift
//
//
//  Created by 김응철 on 9/16/23.
//

import UIKit

import SnapKit
import RSKGrowingTextView
import RxCocoa
import RxSwift

final class MatchingInfoSetupTextViewCell: BaseCollectionViewCell {
  
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
    textView.maximumNumberOfLines = 5
    return textView
  }()
  
  /// 제약조건을 도와주는 `UIView`
  private let supportView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    return view
  }()
  
  // MARK: - Properties
  
  var textViewHandler: ((String) -> Void)?
  
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
      make.height.equalTo(148.0)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    self.textView.rx.text.orEmpty
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, text in
        if text.count > 100 {
          let truncatedText = String(text.prefix(100))
          owner.textView.text = truncatedText
          owner.textViewHandler?(truncatedText)
          return
        }
        owner.textViewHandler?(text)
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Configure
  
  func configure(with text: String) {
    self.textView.text = text
    DispatchQueue.main.async {
      self.textViewHandler?(text)
    }
  }
}

extension MatchingInfoSetupTextViewCell: RSKGrowingTextViewDelegate {
  func textView(
    _ textView: UITextView,
    shouldChangeTextIn range: NSRange,
    replacementText text: String
  ) -> Bool {
    if text.contains("\n") {
      return false
    }
    return true
  }
}
