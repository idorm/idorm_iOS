//
//  CommunityPopularCollectionVIewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/20.
//

import UIKit
import SnapKit

class CommunityPopularCollectionVIewCell: UICollectionViewCell {
  // MARK: - Properties
  static let identifieir = "CommunityPopularCollectionVIewCell"
  
  lazy var popularLabel: UILabel = {
    let label = UILabel()
    label.text = "인기"
    label.textColor = .mainColor
    label.font = .init(name: Font.regular.rawValue, size: 10)
    
    return label
  }()
  
  lazy var contentsLabel: UILabel = {
    let label = UILabel()
    label.text = "3 기숙사 카페 혜윰메뉴 올려드립니다! 제가"
    label.font = .init(name: Font.regular.rawValue, size: 12)
    label.textColor = .black
    label.lineBreakMode = .byCharWrapping
    label.numberOfLines = 0
    
    return label
  }()
  
  lazy var messageImg: UIImageView = {
    let iv = UIImageView()
    iv.image = UIImage(named: "message")
    
    return iv
  }()
  
  lazy var pictureImg: UIImageView = {
    let iv = UIImageView()
    iv.image = UIImage(named: "picture_small")
    
    return iv
  }()

  lazy var likeImg: UIImageView = {
    let iv = UIImageView()
    iv.image = UIImage(named: "like")
    
    return iv
  }()
  
  lazy var messageCountLabel: UILabel = {
    let label = UILabel()
    label.textColor = .darkgrey_custom
    label.font = .init(name: Font.medium.rawValue, size: 10)
    label.text = "100"
    
    return label
  }()
  
  lazy var pictureCountLabel: UILabel = {
    let label = UILabel()
    label.textColor = .darkgrey_custom
    label.font = .init(name: Font.medium.rawValue, size: 10)
    label.text = "100"
    
    return label
  }()

  lazy var likeCountLabel: UILabel = {
    let label = UILabel()
    label.textColor = .darkgrey_custom
    label.font = .init(name: Font.medium.rawValue, size: 10)
    label.text = "100"
    
    return label
  }()
  
  // MARK: - Helpers
  func configureUI() {
    contentView.layer.cornerRadius = 8
    contentView.layer.masksToBounds = true
    contentView.backgroundColor = .white
    
    let messageStack = getStackView(img: messageImg, label: messageCountLabel)
    let pictureStack = getStackView(img: pictureImg, label: pictureCountLabel)
    let likeStack = getStackView(img: likeImg, label: likeCountLabel)
    
    [ popularLabel, contentsLabel, messageStack, pictureStack, likeStack ]
      .forEach { contentView.addSubview($0) }
    
    popularLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(10)
      make.top.equalToSuperview().inset(15)
    }
    
    contentsLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(10)
      make.top.equalTo(popularLabel.snp.bottom).offset(4)
      make.bottom.equalTo(messageStack.snp.top).offset(-30)
    }
    
    likeStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(10)
      make.bottom.equalToSuperview().inset(16.5)
    }
    
    messageStack.snp.makeConstraints { make in
      make.leading.equalTo(likeStack.snp.trailing).offset(8)
      make.centerY.equalTo(likeStack)
    }
    
    pictureStack.snp.makeConstraints { make in
      make.leading.equalTo(messageStack.snp.trailing).offset(8)
      make.centerY.equalTo(likeStack)
    }
  }
  
  private func getStackView(img: UIImageView, label: UILabel) -> UIStackView {
    let stack = UIStackView(arrangedSubviews: [ img, label ])
    stack.axis = .horizontal
    stack.spacing = 3
    stack.alignment = .center
    
    return stack
  }
}
