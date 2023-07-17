//
//  PopularPostCell.swift
//  idorm
//
//  Created by 김응철 on 2023/01/11.
//

import UIKit

import SnapKit

final class PopularPostCell: UICollectionViewCell {
  
  // MARK: - Properties
  
  private let popularLabel: UILabel = {
    let lb = UILabel()
    lb.text = "인기"
    lb.textColor = .idorm_blue
    lb.font = .init(name: IdormFont_deprecated.bold.rawValue, size: 12)
    
    return lb
  }()
  
  private let contentsLabel: UILabel = {
    let lb = UILabel()
    lb.text = "3 기숙사 카페 혜윰메뉴 올려드립니다! 제가"
    lb.font = .init(name: IdormFont_deprecated.regular.rawValue, size: 12)
    lb.textColor = .black
    lb.lineBreakMode = .byCharWrapping
    lb.numberOfLines = 3
    
    return lb
  }()
  
  private let messageCountLabel: UILabel = {
    let lb = UILabel()
    lb.textColor = .idorm_gray_400
    lb.font = .init(name: IdormFont_deprecated.regular.rawValue, size: 12)
    lb.text = "100"
    
    return lb
  }()
  
  private let pictureCountLabel: UILabel = {
    let lb = UILabel()
    lb.textColor = .idorm_gray_400
    lb.font = .init(name: IdormFont_deprecated.regular.rawValue, size: 12)
    lb.text = "100"
    
    return lb
  }()
  
  private let likeCountLabel: UILabel = {
    let lb = UILabel()
    lb.textColor = .idorm_gray_400
    lb.font = .init(name: IdormFont_deprecated.regular.rawValue, size: 12)
    lb.text = "100"
    
    return lb
  }()
  
  private let messageImageView = UIImageView(image: UIImage(named: "speechBubble_double_small"))
  private let pictureImageView = UIImageView(image: UIImage(named: "picture_small"))
  private let likeImageView = UIImageView(image: UIImage(named: "thumbsup_small"))
  
  // MARK: - INITIALIZER
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupStyles()
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Setup

extension PopularPostCell: BaseView {
  
  func configure(_ post: CommunityResponseModel.Posts) {
    contentsLabel.text = post.content
    likeCountLabel.text = "\(post.likesCount)"
    pictureCountLabel.text = "\(post.imagesCount)"
    messageCountLabel.text = "\(post.commentsCount)"
  }
  
  func setupStyles() {
    contentView.layer.cornerRadius = 8
    contentView.layer.masksToBounds = true
    contentView.backgroundColor = .white
  }
  
  func setupLayouts() {
    [
      self.popularLabel,
      self.contentsLabel,
      self.likeImageView,
      self.likeCountLabel,
      self.messageImageView,
      self.messageCountLabel,
      self.pictureImageView,
      self.pictureCountLabel
    ].forEach {
      self.contentView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.popularLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(10)
      make.top.equalToSuperview().inset(15)
    }
    
    self.contentsLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(10)
      make.top.equalTo(self.popularLabel.snp.bottom).offset(4)
    }
    
    self.likeImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(10)
      make.bottom.equalToSuperview().inset(12)
    }
    
    self.likeCountLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.likeImageView.snp.trailing).offset(3)
      make.centerY.equalTo(self.likeImageView)
    }
    
    self.messageImageView.snp.makeConstraints { make in
      make.leading.equalTo(self.likeCountLabel.snp.trailing).offset(8)
      make.bottom.equalToSuperview().inset(12)
    }
    
    self.messageCountLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.messageImageView.snp.trailing).offset(3)
      make.centerY.equalTo(self.messageImageView)
    }
    
    self.pictureImageView.snp.makeConstraints { make in
      make.leading.equalTo(self.messageCountLabel.snp.trailing).offset(8)
      make.bottom.equalToSuperview().inset(12)
    }
    
    self.pictureCountLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.pictureImageView.snp.trailing).offset(3)
      make.centerY.equalTo(self.pictureImageView)
    }
  }
}
