//
//  CommunityPostingContentCell.swift
//  idorm
//
//  Created by 김응철 on 9/28/23.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import RSKPlaceholderTextView

final class CommunityPostingContentCell: BaseCollectionViewCell {
  
  // MARK: - UI Components
  
  private let contentTextView: RSKPlaceholderTextView = {
    let textView = RSKPlaceholderTextView()
    textView.attributedPlaceholder = NSAttributedString(
      string: "기숙사에 있는 학우들에게 질문하거나\n함께 이야기를 나누어 보세요.",
      attributes: [
        .foregroundColor: UIColor.iDormColor(.iDormGray200),
        .font: UIFont.iDormFont(.medium, size: 16.0)
      ]
    )
    textView.textContainerInset = .zero
    textView.font = .iDormFont(.medium, size: 16.0)
    textView.textColor = .black
    return textView
  }()
  
  // MARK: - Properties
  
  var textViewHandler: ((String) -> Void)?
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.backgroundColor = .white
  }
  
  override func setupLayouts() {
    self.addSubview(self.contentTextView)
  }
  
  override func setupConstraints() {
    self.contentTextView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    self.contentTextView.rx.text.orEmpty.asDriver()
      .drive(with: self) { owner, text in
        owner.textViewHandler?(text)
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Configure
  
  func configure(with content: String) {
    self.contentTextView.text = content
  }
}
