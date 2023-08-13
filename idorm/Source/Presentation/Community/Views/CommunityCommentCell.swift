//
//  CommunityDetailTableViewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/21.
//

import UIKit

import SnapKit
import Kingfisher

final class CommunityCommentCell: UICollectionViewCell, BaseView {
  
  // MARK: - UI Components
  
  /// 유저의 사진을 보여주는 `UIImageView`
  private let profileImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFill
    iv.backgroundColor = .iDormColor(.iDormGray300)
    iv.layer.cornerRadius = 8
    iv.layer.masksToBounds = true
    return iv
  }()
  
  /// 유저의 닉네임 `UILabel`
  private let nicknameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = .iDormFont(.medium, size: 14.0)
    return label
  }()
  
  /// 유저의 댓글 단 시간 `UILabel`
  private let timeLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.regular, size: 12.0)
    label.textColor = .iDormColor(.iDormGray300)
    return label
  }()
  
  /// `nicknameLabel`, `timeLabel`을 가지고 있는 `UIStackView`
  private lazy var profileStackView: UIStackView = {
    let sv = UIStackView(arrangedSubviews: [self.nicknameLabel, self.timeLabel])
    sv.axis = .vertical
    sv.alignment = .leading
    return sv
  }()
  
  /// 옵션 `UIButton`
  private let optionButton: iDormButton = {
    let image = UIImage.iDormIcon(.option)
    let button = iDormButton("", image: image)
    return button
  }()
  
  /// 유저의 댓글 내용 `UILabel`
  private let contentLabel: UILabel = {
    let label = UILabel()
    label.textColor = .iDormColor(.iDormGray400)
    label.font = .iDormFont(.medium, size: 14.0)
    label.numberOfLines = 0
    return label
  }()
  
  /// 답글 쓰기 `UIButton`
  private let replyButton: iDormButton = {
    let button = iDormButton("답글 쓰기", image: nil)
    button.contentInset = .init(top: 6.0, leading: 10.0, bottom: 6.0, trailing: 10.0)
    button.baseBackgroundColor = .iDormColor(.iDormGray100)
    button.baseForegroundColor = .black
    button.isHidden = true
    return button
  }()
  
  /// 하단의 경계를 나타내주는 `UIView`
  private let bottomDivider: UIView = {
    let view = UIView()
    view.backgroundColor = .iDormColor(.iDormGray200)
    return view
  }()
  
  /// 첫 번째 답글에서 나타나는 `UIImageView`
  private let replyImageView: UIImageView = {
    let imageView = UIImageView()
    let image: UIImage? = .iDormIcon(.reply)?
      .withTintColor(.iDormColor(.iDormGray200))
    imageView.image = image
    imageView.isHidden = true
    return imageView
  }()
  
  // MARK: - Setup
  
  func setupStyles() {
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
      self.profileStackView,
      self.optionButton,
      self.contentLabel,
      self.replyButton,
      self.bottomDivider
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
  
  var replyButtonCompletion: ((Int) -> Void)?
  var optionButtonCompletion: ((Int) -> Void)?
  
  private var comment: Comment!
  private var isInitialized: Bool = false
  private var topConstraints: Constraint?
  private var bottomConstarints: Constraint?
  
  // MARK: - LIFECYCLE
  
  override func prepareForReuse() {
    super.prepareForReuse()
    profileImageView.image = nil
  }
  
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
  
  func configure(_ comment: Comment) {
    self.comment = comment
    nicknameLabel.text = comment.nickname ?? "탈퇴한 사용자"
    timeLabel.text = TimeUtils.detailPost(comment.createdAt)
    contentsLabel.text = comment.content
    
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
    
    if !comment.isAnonymous {
      if let url = comment.profileUrl {
        profileImageView.kf.setImage(with: URL(string: url)!)
      } else {
        profileImageView.image = UIImage(named: "square_human_noShadow")
      }
    } else {
      profileImageView.image = UIImage(named: "square_human_noShadow")
    }
  }
}
