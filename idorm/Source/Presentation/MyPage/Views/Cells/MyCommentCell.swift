//
//  MyCommentCell.swift
//  idorm
//
//  Created by 김응철 on 2023/04/29.
//

import UIKit

import SnapKit

final class MyCommentCell: UITableViewCell, BaseView {
  
  // MARK: - UI Components
  
  private let nicknameLabel: UILabel = {
    let lb = UILabel()
    lb.textColor = .black
    lb.font = .idormFont(.medium, size: 14)
    return lb
  }()
  
  private let timeLabel: UILabel = {
    let lb = UILabel()
    lb.textColor = .idorm_gray_300
    lb.font = .idormFont(.regular, size: 12)
    return lb
  }()
  
  private let contentLabel: UILabel = {
    let lb = UILabel()
    lb.textColor = .idorm_gray_400
    lb.font = .idormFont(.medium, size: 14)
    lb.numberOfLines = 0
    return lb
  }()
  
  private let profileImageView: UIImageView = {
    let iv = UIImageView()
    iv.backgroundColor = .idorm_gray_300
    iv.layer.cornerRadius = 8.0
    return iv
  }()
  
  private lazy var nicknameStack: UIStackView = {
    let sv = UIStackView()
    [
      nicknameLabel,
      timeLabel
    ].forEach {
      sv.addArrangedSubview($0)
    }
    sv.axis = .vertical
    return sv
  }()
  
  private let confirmBodyButton: idormButton = {
    let btn = idormButton("본문 확인")
    btn.configuration?.baseBackgroundColor = .idorm_gray_100
    btn.configuration?.baseForegroundColor = .black
    return btn
  }()
  
  private let lineView: UIView = {
    let view = UIView()
    view.backgroundColor = .idorm_gray_200
    return view
  }()
  
  // MARK: - Properties
  
  static let identifier = "MyCommentCell"
  var comment: CommunityResponseModel.SubComment?
  var buttonCompletion: ((Int?) -> Void)?
  
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
  
  // MARK: - Setup
  
  func setupStyles() {
    selectionStyle = .none
    confirmBodyButton.addTarget(
      self,
      action: #selector(didTapConfirmBodyButton),
      for: .touchUpInside
    )
  }
  
  func setupLayouts() {
    [
      nicknameStack,
      contentLabel,
      confirmBodyButton,
      profileImageView,
      lineView
    ].forEach {
      contentView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    profileImageView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(16)
      make.leading.equalToSuperview().inset(24)
      make.width.height.equalTo(42.0)
    }
    
    nicknameStack.snp.makeConstraints { make in
      make.centerY.equalTo(profileImageView)
      make.leading.equalTo(profileImageView.snp.trailing).offset(10)
    }
    
    contentLabel.snp.makeConstraints { make in
      make.top.equalTo(profileImageView.snp.bottom).offset(2)
      make.leading.equalTo(profileImageView.snp.trailing).offset(10)
      make.trailing.equalToSuperview().inset(24)
    }
    
    confirmBodyButton.snp.makeConstraints { make in
      make.leading.equalTo(contentLabel.snp.leading)
      make.top.equalTo(contentLabel.snp.bottom).offset(10)
      make.bottom.equalToSuperview().inset(16)
    }
    
    lineView.snp.makeConstraints { make in
      make.bottom.leading.trailing.equalToSuperview()
      make.height.equalTo(1)
    }
  }
  
  // MARK: - Helpers
  
  func configure(_ comment: CommunityResponseModel.SubComment) {
    contentLabel.text = comment.content
    nicknameLabel.text = comment.nickname
    timeLabel.text = TimeUtils.detailPost(comment.createdAt)
    self.comment = comment
    // TODO: 사용자 프로필 이미지 설정
  }
  
  // MARK: - Selectros
  
  @objc
  private func didTapConfirmBodyButton() {
    buttonCompletion?(comment?.postId)
  }
}
