//
//  CommentView.swift
//  idorm
//
//  Created by 김응철 on 2023/01/23.
//

import UIKit

import SnapKit
import RSKGrowingTextView
import GrowingTextView

final class CommentView: UIView {
  
  // MARK: - Properties
  
  private let anonymousLabel: UILabel = {
    let lb = UILabel()
    lb.text = "익명"
    lb.font = .init(name: IdormFont_deprecated.medium.rawValue, size: 12)
    lb.textColor = .black
    
    return lb
  }()
  
  let anonymousButton: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "circle_blue_gray"), for: .selected)
    btn.setImage(UIImage(named: "circle_gray"), for: .normal)
    btn.isSelected = true
    
    return btn
  }()
  
  let textView: GrowingTextView = {
    let tv = GrowingTextView()
    tv.attributedPlaceholder = NSAttributedString(
      string: "댓글을 입력해주세요.",
      attributes: [
        .font: UIFont.iDormFont(.regular, size: 12),
        .foregroundColor: UIColor.idorm_gray_400
      ])
    tv.font = .iDormFont(.regular, size: 12)
    tv.layer.cornerRadius = 15
    tv.maxHeight = 100
    tv.minHeight = 32
    tv.backgroundColor = .idorm_gray_100
    tv.trimWhiteSpaceWhenEndEditing = true
    tv.textContainerInset = UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 42)
    
    return tv
  }()
  
  let sendButton: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "paperAirplane"), for: .disabled)
    btn.setImage(UIImage(named: "paperAirplane_blue"), for: .normal)
    
    return btn
  }()
  
  // MARK: - Initializer
  
  init() {
    super.init(frame: .zero)
    setupStyles()
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension CommentView: BaseView {
  func setupStyles() {
    backgroundColor = .white
    
    layer.shadowOffset = CGSize(width: 0, height: 3)
    layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
    layer.shadowRadius = 15
    layer.shadowOpacity = 1
  }
  
  func setupLayouts() {
    [
      anonymousLabel,
      anonymousButton,
      textView,
      sendButton
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    anonymousLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.bottom.equalToSuperview().inset(16)
    }
    
    anonymousButton.snp.makeConstraints { make in
      make.leading.equalTo(anonymousLabel.snp.trailing).offset(5.5)
      make.centerY.equalTo(anonymousLabel)
    }
    
    textView.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview().inset(8)
      make.leading.equalTo(anonymousButton.snp.trailing).offset(8.5)
      make.trailing.equalToSuperview().inset(24)
    }
    
    sendButton.snp.makeConstraints { make in
      make.trailing.equalTo(textView.snp.trailing).offset(-12)
      make.bottom.equalTo(textView.snp.bottom).offset(-4)
    }    
  }
}
