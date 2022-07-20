//
//  CommunityPostCollectionViewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/20.
//

import UIKit
import SnapKit

class CommunityPostCollectionViewCell: UICollectionViewCell {
  // MARK: - Properties
  static let identifier = "CommunityPostCollectionViewCell"
  
  let likeImg = UIImageView(image: UIImage(named: "like_medium"))
  let messageImg = UIImageView(image: UIImage(named: "message_medium"))
  let pictureImg = UIImageView(image: UIImage(named: "picture_medium"))
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = "제목"
    label.font = .init(name: Font.medium.rawValue, size: 14)
    label.textColor = .black
    label.numberOfLines = 1
    
    return label
  }()
  
  lazy var contentsLabel: UILabel = {
    let label = UILabel()
    label.font = .init(name: Font.medium.rawValue, size: 12)
    label.textColor = .darkgrey_custom
    label.text = "내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용내용"
    label.numberOfLines = 1
    
    return label
  }()
  
  lazy var userInfoLabel: UILabel = {
    let label = UILabel()
    label.textColor = .grey_custom
    label.font = .init(name: Font.medium.rawValue, size: 10)
    label.text = "닉네임닉네임닉네임 ∙ 1분 전"
    
    return label
  }()
  
  lazy var separateLine: UIView = {
    let view = UIView()
    view.backgroundColor = .init(rgb: 0xF4F2FA)
    
    return view
  }()
  
  lazy var likeCountLabel: UILabel = {
    let label = UILabel()
    label.font = .init(name: Font.medium.rawValue, size: 10)
    label.textColor = .grey_custom
    label.text = "100"
    
    return label
  }()
  
  lazy var messageCountLabel: UILabel = {
    let label = UILabel()
    label.font = .init(name: Font.medium.rawValue, size: 10)
    label.textColor = .grey_custom
    label.text = "100"
    
    return label
  }()

  lazy var pictureCountLabel: UILabel = {
    let label = UILabel()
    label.font = .init(name: Font.medium.rawValue, size: 10)
    label.textColor = .grey_custom
    label.text = "100"
    
    return label
  }()
  
  // MARK: - Helpers
  func configureUI() {
    contentView.backgroundColor = .white
    
    let likeStack = getStackView(img: likeImg, label: likeCountLabel)
    let messageStack = getStackView(img: messageImg, label: messageCountLabel)
    let pictureStack = getStackView(img: pictureImg, label: pictureCountLabel)
    
    [ titleLabel, contentsLabel, userInfoLabel, separateLine, likeStack, messageStack, pictureStack ]
      .forEach { contentView.addSubview($0) }
    
    titleLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalToSuperview().inset(12)
    }
    
    contentsLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(4)
      make.leading.trailing.equalToSuperview().inset(24)
    }
    
    userInfoLabel.snp.makeConstraints { make in
      make.top.equalTo(contentsLabel.snp.bottom).offset(12)
      make.leading.equalToSuperview().inset(24)
    }
    
    separateLine.snp.makeConstraints { make in
      make.top.equalTo(userInfoLabel.snp.bottom).offset(14)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(1)
    }
    
    likeStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24.5)
      make.bottom.equalToSuperview().inset(13.5)
    }
    
    messageStack.snp.makeConstraints { make in
      make.leading.equalTo(likeStack.snp.trailing).offset(13.5)
      make.centerY.equalTo(likeStack)
    }
    
    pictureStack.snp.makeConstraints { make in
      make.leading.equalTo(messageStack.snp.trailing).offset(13.5)
      make.centerY.equalTo(likeStack)
    }
  }
  
  private func getStackView(img: UIImageView, label: UILabel) -> UIStackView {
    let stack = UIStackView(arrangedSubviews: [ img, label ])
    stack.axis = .horizontal
    stack.spacing = 5.5
    
    return stack
  }
}
