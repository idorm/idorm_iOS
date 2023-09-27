//
//  CommunityPostContentCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/20.
//

import UIKit

import SnapKit
import Kingfisher

/// 게시글의 유저의 정보 및 게시글 내용이 들어가는 `UICollectionViewCell`
final class CommunityPostContentCell: UICollectionViewCell, BaseViewProtocol {
  
  // MARK: - UI Components
  
  /// 유저의 프로필 사진이 들어가는 `UIImageView`
  private let profileImageView: UIImageView = {
    let iv = UIImageView()
    iv.image = .iDormImage(.human)
    iv.layer.cornerRadius = 8.0
    iv.layer.masksToBounds = true
    return iv
  }()
  
  /// 유저의 닉네임이 들어가는 `UILabel`
  private let nicknameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = .iDormFont(.medium, size: 14)
    return label
  }()
  
  /// 게시글이 작성된 시간을 알려주는 `UILabel`
  private let timeLabel: UILabel = {
    let label = UILabel()
    label.textColor = .iDormColor(.iDormGray300)
    label.font = .iDormFont(.medium, size: 12)
    return label
  }()

  /// `nicknameLabel`과 `timeLabel`의 수직 성분의 `UIStackView`
  private lazy var profileStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [
      nicknameLabel,
      timeLabel
    ])
    stack.axis = .vertical
    return stack
  }()
  
  /// 게시글의 제목 `UILabel`
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.medium, size: 16)
    label.textColor = .black
    label.numberOfLines = 2
    return label
  }()
  
  /// 게시글의 내용 `UILabel`
  private let contentsLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.regular, size: 14)
    label.textColor = .black
    label.numberOfLines = 0
    return label
  }()
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  func setupStyles() {}
  
  func setupLayouts() {
    [
      self.profileImageView,
      self.profileStackView,
      self.titleLabel,
      self.contentsLabel
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.profileImageView.snp.makeConstraints { make in
      make.top.leading.equalToSuperview()
      make.size.equalTo(42.0)
    }
    
    self.profileStackView.snp.makeConstraints { make in
      make.centerY.equalTo(self.profileImageView)
      make.leading.equalTo(self.profileImageView.snp.trailing).offset(10.0)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview()
      make.top.equalTo(self.profileImageView.snp.bottom).offset(12.0)
    }
    
    self.contentsLabel.snp.makeConstraints { make in
      make.directionalHorizontalEdges.bottom.equalToSuperview()
      make.top.equalTo(self.titleLabel.snp.bottom).offset(12.0)
    }
  }
  
  // MARK: - Configure
  
  /// 외부에서 주입된 `Post`타입을 가지고 UI를 구성합니다.
  func configure(with post: Post) {
    // Data Binding
    self.profileImageView.image = .iDormImage(.human)
    if !post.isAnonymous,
       let profileURL = post.profileURL
    { self.profileImageView.kf.setImage(with: URL(string: profileURL)) }
    self.titleLabel.text = post.title
    self.nicknameLabel.text = post.nickname
    self.timeLabel.text = post.createdAtPost
    self.contentsLabel.text = post.content
  }
}
