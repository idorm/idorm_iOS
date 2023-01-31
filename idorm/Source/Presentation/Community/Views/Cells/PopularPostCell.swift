//
//  PopularPostCell.swift
//  idorm
//
//  Created by 김응철 on 2023/01/11.
//

import UIKit

import SnapKit

final class PopularPostCell: UICollectionViewCell, BaseView {
  
  // MARK: - Properties
  
  static let identifier = "PopularPostCell"
  
  private let popularLabel: UILabel = {
    let lb = UILabel()
    lb.text = "인기"
    lb.textColor = .idorm_blue
    lb.font = .init(name: MyFonts.bold.rawValue, size: 12)
    
    return lb
  }()

  private let contentsLabel: UILabel = {
    let lb = UILabel()
    lb.text = "3 기숙사 카페 혜윰메뉴 올려드립니다! 제가"
    lb.font = .init(name: MyFonts.regular.rawValue, size: 12)
    lb.textColor = .black
    lb.lineBreakMode = .byCharWrapping
    lb.numberOfLines = 0
    
    return lb
  }()
  
  private let messageCountLabel: UILabel = {
    let lb = UILabel()
    lb.textColor = .idorm_gray_400
    lb.font = .init(name: MyFonts.regular.rawValue, size: 12)
    lb.text = "100"
    
    return lb
  }()
  
  private let pictureCountLabel: UILabel = {
    let lb = UILabel()
    lb.textColor = .idorm_gray_400
    lb.font = .init(name: MyFonts.regular.rawValue, size: 12)
    lb.text = "100"
    
    return lb
  }()

  private let likeCountLabel: UILabel = {
    let lb = UILabel()
    lb.textColor = .idorm_gray_400
    lb.font = .init(name: MyFonts.regular.rawValue, size: 12)
    lb.text = "100"
    
    return lb
  }()
  
  private let messageImageView = UIImageView(image: UIImage(named: "speechBubble_double_small"))
  private let pictureImageView = UIImageView(image: UIImage(named: "picture_small"))
  private let likeImageView = UIImageView(image: UIImage(named: "thumbsup_small"))
  private lazy var messageStack = stackView([messageImageView, messageCountLabel])
  private lazy var pictureStack = stackView([pictureImageView, pictureCountLabel])
  private lazy var likeStack = stackView([likeImageView, likeCountLabel])
  
  // MARK: - Initialize
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupStyles()
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  func setupStyles() {
    contentView.layer.cornerRadius = 8
    contentView.layer.masksToBounds = true
    contentView.backgroundColor = .white
  }
  
  func setupLayouts() {
    [
      popularLabel,
      contentsLabel,
      messageStack,
      pictureStack,
      likeStack
    ].forEach { contentView.addSubview($0) }
  }
  
  func setupConstraints() {
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
      make.bottom.equalToSuperview().inset(10)
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
  
  // MARK: - Helpers
  
  private func stackView(_ views: [UIView]) -> UIStackView {
    let sv = UIStackView(arrangedSubviews: views)
    sv.axis = .horizontal
    sv.spacing = 3
    sv.alignment = .center
    
    return sv
  }
  
  func configure(_ post: CommunityResponseModel.Posts) {
    contentsLabel.text = post.content
    likeCountLabel.text = "\(post.likesCount)"
    pictureCountLabel.text = "\(post.imagesCount)"
    messageCountLabel.text = "\(post.commentsCount)"
  }
}
