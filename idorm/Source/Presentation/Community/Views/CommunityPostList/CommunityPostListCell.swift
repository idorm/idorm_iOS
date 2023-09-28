//
//  PostCell.swift
//  idorm
//
//  Created by 김응철 on 2023/01/11.
//

import UIKit

import SnapKit

final class CommunityPostListCell: BaseCollectionViewCell {
  
  // MARK: - UI Components
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.medium, size: 14.0)
    label.textColor = .black
    return label
  }()
  
  private let contentLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.medium, size: 12.0)
    label.textColor = .iDormColor(.iDormGray400)
    return label
  }()
  
  private let nicknameLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.regular, size: 12.0)
    label.textColor = .iDormColor(.iDormGray300)
    return label
  }()
  
  private let timeLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.medium, size: 12.0)
    label.textColor = .iDormColor(.iDormGray300)
    return label
  }()
  
  private let dotLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.regular, size: 12.0)
    label.text = "∙"
    label.textColor = .iDormColor(.iDormGray300)
    return label
  }()
  
  private let lineView: UIView = {
    let view = UIView()
    view.backgroundColor = .iDormColor(.iDormGray200)
    return view
  }()
  
  private let likesCountButton: iDormButton = {
    let button = iDormButton()
    button.image = .iDormIcon(.thumb)
    button.font = .iDormFont(.medium, size: 12.0)
    button.baseBackgroundColor = .white
    button.baseForegroundColor = .iDormColor(.iDormGray300)
    button.imagePadding = 5.0
    button.contentInset = .zero
    button.isUserInteractionEnabled = false
    return button
  }()
  
  private let commentsCountButton: iDormButton = {
    let button = iDormButton()
    button.image = .iDormIcon(.speechBubble)
    button.font = .iDormFont(.medium, size: 12.0)
    button.baseBackgroundColor = .white
    button.baseForegroundColor = .iDormColor(.iDormGray300)
    button.imagePadding = 5.0
    button.contentInset = .zero
    button.isUserInteractionEnabled = false
    return button
  }()
  
  private let imagesCountButton: iDormButton = {
    let button = iDormButton()
    button.image = .iDormIcon(.photo)
    button.font = .iDormFont(.medium, size: 12.0)
    button.baseBackgroundColor = .white
    button.baseForegroundColor = .iDormColor(.iDormGray300)
    button.imagePadding = 5.0
    button.contentInset = .zero
    button.isUserInteractionEnabled = false
    return button
  }()
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.backgroundColor = .white
  }
  
  override func setupLayouts() {
    [
      self.titleLabel,
      self.contentLabel,
      self.nicknameLabel,
      self.dotLabel,
      self.timeLabel,
      self.lineView,
      self.likesCountButton,
      self.commentsCountButton,
      self.imagesCountButton
    ].forEach {
      self.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24.0)
      make.top.equalToSuperview().inset(12.0)
    }
    
    self.contentLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24.0)
      make.top.equalTo(self.titleLabel.snp.bottom).offset(4.0)
    }
    
    self.nicknameLabel.snp.makeConstraints { make in
      make.top.equalTo(self.contentLabel.snp.bottom).offset(12.0)
      make.leading.equalToSuperview().inset(24.0)
    }
    
    self.dotLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.nicknameLabel.snp.trailing).offset(4.0)
      make.centerY.equalTo(self.nicknameLabel)
    }
    
    self.timeLabel.snp.makeConstraints { make in
      make.leading.equalTo(dotLabel.snp.trailing).offset(4.0)
      make.centerY.equalTo(nicknameLabel)
    }
    
    self.lineView.snp.makeConstraints { make in
      make.top.equalTo(self.nicknameLabel.snp.bottom).offset(14.0)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(1)
    }
    
    self.likesCountButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24.0)
      make.top.equalTo(self.lineView.snp.bottom).offset(12.0)
    }
    
    self.commentsCountButton.snp.makeConstraints { make in
      make.centerY.equalTo(self.likesCountButton)
      make.leading.equalTo(self.likesCountButton.snp.trailing).offset(12.0)
    }
    
    self.imagesCountButton.snp.makeConstraints { make in
      make.leading.equalTo(self.commentsCountButton.snp.trailing).offset(4)
      make.centerY.equalTo(self.likesCountButton)
    }
  }
  
  // MARK: - Configure
  
  func configure(with post: Post) {
    self.titleLabel.text = post.title
    self.contentLabel.text = post.content
    self.nicknameLabel.text = post.nickname
    self.timeLabel.text = post.createdAtPostList
    self.likesCountButton.title = "\(post.likesCount)"
    self.commentsCountButton.title = "\(post.commentsCount)"
    self.imagesCountButton.title = "\(post.imagesCount)"
    if post.imagesCount == 0 {
      self.imagesCountButton.isHidden = true
    } else {
      self.imagesCountButton.isHidden = false
    }
  }
}
