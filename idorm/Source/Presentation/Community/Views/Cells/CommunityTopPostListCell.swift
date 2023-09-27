//
//  PopularPostCell.swift
//  idorm
//
//  Created by 김응철 on 2023/01/11.
//

import UIKit

import SnapKit

final class CommunityTopPostListCell: BaseCollectionViewCell {
  
  // MARK: - UI Components
  
  private let popularLabel: UILabel = {
    let label = UILabel()
    label.textColor = .iDormColor(.iDormBlue)
    label.font = .iDormFont(.bold, size: 12.0)
    label.text = "인기"
    return label
  }()
  
  private let contentLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.regular, size: 12.0)
    label.textColor = .black
    label.lineBreakMode = .byCharWrapping
    label.numberOfLines = 3
    return label
  }()
  
  private let likesCountButton: iDormButton = {
    let button = iDormButton()
    button.image = .iDormIcon(.thumb)?.resize(newSize: 10.0)
    button.font = .iDormFont(.medium, size: 12.0)
    button.baseBackgroundColor = .white
    button.baseForegroundColor = .iDormColor(.iDormGray300)
    button.imagePadding = 4.0
    button.contentInset = .zero
    button.isUserInteractionEnabled = false
    return button
  }()
  
  private let commentsCountButton: iDormButton = {
    let button = iDormButton()
    button.image = .iDormIcon(.speechBubble)?.resize(newSize: 10.0)
    button.font = .iDormFont(.medium, size: 12.0)
    button.baseBackgroundColor = .white
    button.baseForegroundColor = .iDormColor(.iDormGray300)
    button.imagePadding = 4.0
    button.contentInset = .zero
    button.isUserInteractionEnabled = false
    return button
  }()
  
  private let imagesCountButton: iDormButton = {
    let button = iDormButton()
    button.image = .iDormIcon(.photo)?.resize(newSize: 10.0)
    button.font = .iDormFont(.medium, size: 12.0)
    button.baseBackgroundColor = .white
    button.baseForegroundColor = .iDormColor(.iDormGray300)
    button.imagePadding = 4.0
    button.contentInset = .zero
    button.isUserInteractionEnabled = false
    return button
  }()
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.contentView.layer.shadowOpacity = 0.11
    self.contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
    self.contentView.layer.shadowRadius = 2.0
    self.contentView.layer.cornerRadius = 8.0
    self.contentView.backgroundColor = .white
  }
  
  override func setupLayouts() {
    [
      self.popularLabel,
      self.contentLabel,
      self.likesCountButton,
      self.commentsCountButton,
      self.imagesCountButton,
    ].forEach {
      self.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.popularLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(10.0)
      make.top.equalToSuperview().inset(15.0)
    }
    
    self.contentLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(10.0)
      make.top.equalTo(self.popularLabel.snp.bottom).offset(4.0)
    }
    
    self.likesCountButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(10.0)
      make.bottom.equalToSuperview().inset(12.0)
    }
    
    self.commentsCountButton.snp.makeConstraints { make in
      make.leading.equalTo(self.likesCountButton.snp.trailing).offset(8.0)
      make.bottom.equalToSuperview().inset(12.0)
    }
    
    self.imagesCountButton.snp.makeConstraints { make in
      make.leading.equalTo(self.commentsCountButton.snp.trailing).offset(8.0)
      make.bottom.equalToSuperview().inset(12.0)
    }
  }
  
  // MARK: - Configure
  
  func configure(with post: Post) {
    contentLabel.text = post.content
    likesCountButton.title = "\(post.likesCount)"
    imagesCountButton.title = "\(post.imagesCount)"
    commentsCountButton.title = "\(post.commentsCount)"
  }
}
