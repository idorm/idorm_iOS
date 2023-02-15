//
//  CommunityDetailTableViewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/21.
//

import UIKit

import SnapKit

final class CommentCell: UITableViewCell {
  
  // MARK: - PROPERTIES
  
  static let identifier = "CommentCell"
  
  lazy var profileImageView: UIImageView = {
    let iv = UIImageView()
    iv.backgroundColor = .idorm_gray_300
    iv.layer.cornerRadius = 8
    iv.layer.masksToBounds = true
    
    return iv
  }()
    
  private let nicknameLabel = UIFactory.label(
    "",
    textColor: .black,
    font: .idormFont(.medium, size: 14)
  )
  
  private let timeLabel = UIFactory.label(
    "1시간 전",
    textColor: .idorm_gray_300,
    font: .idormFont(.regular, size: 12)
  )
  
  private lazy var profileStack: UIStackView = {
    let sv = UIStackView(arrangedSubviews: [
      nicknameLabel, timeLabel
    ])
    sv.axis = .vertical
    sv.alignment = .leading
    
    return sv
  }()
  
  lazy var optionButton: UIButton = {
    let btn = UIButton(type: .custom)
    btn.setImage(UIImage(named: "option_gray"), for: .normal)
    
    return btn
  }()
  
  private let contentsLabel = UIFactory.label(
    "",
    textColor: .idorm_gray_400,
    font: .idormFont(.medium, size: 14)
  )
  
  private let replyButton = idormCommunityButton("답글 쓰기")
  private let dividerLine = UIFactory.view(.idorm_gray_200)
  private let replyImageView = UIImageView(image: UIImage(named: "corner_down_right"))
  
  var replyButtonCompletion: ((Int) -> Void)?
  var optionButtonCompletion: ((Int) -> Void)?

  private var comment: OrderedComment!
  private var isInitialized: Bool = false
  private var topConstraints: Constraint?
  private var bottomConstarints: Constraint?
  
  // MARK: - SELECTORS
  
  @objc
  private func didTapReplyButton() {
    guard let commentId = self.comment?.commentId else { return }
    self.replyButtonCompletion?(commentId)
  }
  
  @objc
  private func didTapOptionButton() {
    guard let commentId = self.comment?.commentId else { return }
    self.optionButtonCompletion?(commentId)
  }
  
  // MARK: - HELPERS
  
  private func registerButtonTargets() {
    self.replyButton.addTarget(self, action: #selector(didTapReplyButton), for: .touchUpInside)
    self.optionButton.addTarget(self, action: #selector(didTapOptionButton), for: .touchUpInside)
  }
}

// MARK: - SETUP

extension CommentCell: BaseView {
  func inject(_ comment: OrderedComment) {
    self.comment = comment
    self.nicknameLabel.text = comment.nickname
    self.timeLabel.text = TimeUtils.detailPost(comment.createdAt)
    self.contentsLabel.text = comment.content

    self.setupStyles()
    self.setupLayouts()
    if !self.isInitialized {
      self.isInitialized = true
      self.setupConstraints()
      self.registerButtonTargets()
    }
    
    switch comment.state {
    case .normal(let isRemoved):
      if isRemoved {
        self.topConstraints?.update(inset: 16)
        self.bottomConstarints?.update(inset: 16)
      } else {
        self.topConstraints?.update(inset: 16)
        self.bottomConstarints?.update(inset: 56)
      }
    case .reply:
      self.topConstraints?.update(inset: 16)
      self.bottomConstarints?.update(inset: 16)
    case .firstReply:
      self.topConstraints?.update(inset: 56)
      self.bottomConstarints?.update(inset: 16)
    }
  }

  func setupStyles() {
    contentView.backgroundColor = .white
    self.replyImageView.isHidden = true
    self.replyButton.isHidden = true
    self.contentsLabel.numberOfLines = 0
    
    if self.comment.isLast {
      self.dividerLine.isHidden = false
    } else {
      self.dividerLine.isHidden = true
    }

    switch self.comment.state {
    case .firstReply:
      self.replyImageView.isHidden = false
      self.replyButton.isHidden = true
      self.nicknameLabel.textColor = .idorm_gray_400
      self.contentView.backgroundColor = .idorm_matchingScreen
    case .reply:
      self.replyImageView.isHidden = true
      self.replyButton.isHidden = true
      self.nicknameLabel.textColor = .idorm_gray_400
      self.contentView.backgroundColor = .idorm_matchingScreen
    case .normal(let isRemoved):
      if isRemoved {
        self.replyButton.isHidden = true
        self.replyImageView.isHidden = true
        self.nicknameLabel.text = "삭제"
        self.nicknameLabel.textColor = .idorm_gray_300
        self.contentsLabel.text = "삭제된 댓글입니다."
        self.contentView.backgroundColor = .white
      } else {
        self.replyButton.isHidden = false
        self.replyImageView.isHidden = true
        self.nicknameLabel.textColor = .idorm_gray_400
        self.contentView.backgroundColor = .white
      }
    }
  }
  
  func setupLayouts() {
    [
      self.replyImageView,
      self.profileImageView,
      self.profileStack,
      self.optionButton,
      self.contentsLabel,
      self.replyButton,
      self.dividerLine
    ].forEach {
      self.contentView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.replyImageView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(16)
      make.leading.equalToSuperview().inset(24)
    }
    
    self.profileImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      self.topConstraints = make.top.equalToSuperview().inset(56).constraint
      make.width.height.equalTo(42)
    }
    
    self.profileStack.snp.makeConstraints { make in
      make.centerY.equalTo(profileImageView)
      make.leading.equalTo(profileImageView.snp.trailing).offset(10)
      make.trailing.equalTo(optionButton.snp.leading).offset(-10)
    }
    
    self.contentsLabel.snp.makeConstraints { make in
      make.leading.equalTo(profileStack.snp.leading)
      make.top.equalTo(profileStack.snp.bottom).offset(8)
      make.trailing.equalToSuperview().inset(24)
      self.bottomConstarints = make.bottom.equalToSuperview().inset(56).constraint
    }
    
    self.replyButton.snp.makeConstraints { make in
      make.top.equalTo(contentsLabel.snp.bottom).offset(10)
      make.leading.equalTo(profileStack.snp.leading)
    }
    
    self.optionButton.snp.makeConstraints { make in
      make.top.equalTo(self.profileImageView.snp.top)
      make.trailing.equalToSuperview().inset(14)
    }
    
    self.dividerLine.snp.makeConstraints { make in
      make.bottom.leading.trailing.equalToSuperview()
      make.height.equalTo(1)
    }
  }
}
