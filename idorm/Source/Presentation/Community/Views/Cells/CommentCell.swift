//
//  CommunityDetailTableViewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/21.
//

import UIKit

import SnapKit

final class CommentCell: UITableViewCell {
  
  // MARK: - Properties
  
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
  
  private lazy var replyButton: idormCommunityButton = {
    let btn = idormCommunityButton("답글 쓰기")
    btn.addTarget(self, action: #selector(didTapReplyButton), for: .touchUpInside)
    
    return btn
  }()
  
  private let dividerLine = UIFactory.view(.idorm_gray_200)
  private let replyImageView = UIImageView(image: UIImage(named: "corner_down_right"))
  private var comment: OrderedComment?
  var replyButtonCompletion: ((Int) -> Void)?
  
  // MARK: - Initializer
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupStyles()
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Selectors
  
  @objc
  private func didTapReplyButton() {
    guard let commentId = self.comment?.comment.commentId else { return }
    self.replyButtonCompletion?(commentId)
  }
}

// MARK: - Setup

extension CommentCell: BaseView {
  func inject(_ comment: OrderedComment) {
    self.comment = comment
    nicknameLabel.text = comment.comment.nickname?.isAnonymous
    timeLabel.text = TimeUtils.detailPost(comment.comment.createdAt)
    contentsLabel.text = comment.comment.content
    replyImageView.isHidden = true
    
    if comment.isLast {
      dividerLine.isHidden = false
    } else {
      dividerLine.isHidden = true
    }
    
    switch comment.state {
    case .normal:
      contentView.backgroundColor = .white
      
      replyImageView.snp.updateConstraints { make in
        make.top.equalToSuperview().inset(-24)
      }
      
    case .reply:
      contentView.backgroundColor = .idorm_matchingScreen
      
      replyImageView.snp.updateConstraints { make in
        make.top.equalToSuperview().inset(-24)
      }
      
    case .firstReply:
      contentView.backgroundColor = .idorm_matchingScreen
      replyImageView.isHidden = false
      
      replyImageView.snp.updateConstraints { make in
        make.top.equalToSuperview().inset(16)
      }
    }
  }
  
  func setupStyles() {
    contentView.backgroundColor = .white
  }
  
  func setupLayouts() {
    [
      replyImageView,
      profileImageView,
      profileStack,
      optionButton,
      contentsLabel,
      replyButton,
      dividerLine
    ].forEach {
      contentView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    replyImageView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(16)
      make.leading.equalToSuperview().inset(24)
    }
    
    profileImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(replyImageView.snp.bottom).offset(16)
      make.width.height.equalTo(42)
    }
    
    profileStack.snp.makeConstraints { make in
      make.centerY.equalTo(profileImageView)
      make.leading.equalTo(profileImageView.snp.trailing).offset(10)
      make.trailing.equalTo(optionButton.snp.leading).offset(-10)
    }
    
    contentsLabel.snp.makeConstraints { make in
      make.leading.equalTo(profileStack.snp.leading)
      make.top.equalTo(profileStack.snp.bottom).offset(8)
      make.trailing.equalToSuperview().inset(24)
    }
    
    replyButton.snp.makeConstraints { make in
      make.top.equalTo(contentsLabel.snp.bottom).offset(10)
      make.leading.equalTo(profileStack.snp.leading)
      make.bottom.equalToSuperview().inset(16)
    }
    
    optionButton.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(16)
      make.trailing.equalToSuperview().inset(14)
    }
    
    dividerLine.snp.makeConstraints { make in
      make.bottom.leading.trailing.equalToSuperview()
      make.height.equalTo(1)
    }
  }
}
