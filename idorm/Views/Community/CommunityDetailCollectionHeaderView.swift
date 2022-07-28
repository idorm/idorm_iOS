//
//  CommunityDetailCollectionHeaderView.swift
//  idorm
//
//  Created by 김응철 on 2022/07/20.
//

import UIKit
import SnapKit

class CommunityDetailTableHeaderView: UIView {
  // MARK: - Properties
  static let identifier = "CommunityDetailTableHeaderView"
  
  let likeImg = UIImageView(image: UIImage(named: "like_medium"))
  let messageImg = UIImageView(image: UIImage(named: "message_medium"))
  let pictureImg = UIImageView(image: UIImage(named: "picture_medium"))
  
  let separatorLine = CommunityUtilities.getSeparatorLine()
  let separatorLine2 = CommunityUtilities.getSeparatorLine()
  
  let likeCountLabel = CommunityUtilities.getCountLabel()
  let messageCountLabel = CommunityUtilities.getCountLabel()
  let pictureCountLabel = CommunityUtilities.getCountLabel()
  
  lazy var myImg: UIImageView = {
    let iv = UIImageView()
    iv.backgroundColor = .idorm_gray_300
    iv.layer.cornerRadius = 8
    iv.layer.masksToBounds = true
    
    return iv
  }()
  
  lazy var nicknameLabel: UILabel = {
    let label = UILabel()
    label.text = "닉네임"
    label.textColor = .black
    label.font = .init(name: Font.medium.rawValue, size: 14)
    
    return label
  }()
  
  lazy var timeLabel: UILabel = {
    let label = UILabel()
    label.textColor = .idorm_gray_300
    label.font = .init(name: Font.medium.rawValue, size: 10)
    label.text = "일주일 전"
    
    return label
  }()
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = "제목"
    label.font = .init(name: Font.medium.rawValue, size: 14)
    label.textColor = .black
    label.textAlignment = .left
    label.numberOfLines = 2
    
    return label
  }()
  
  lazy var contentsLabel: UILabel = {
    let label = UILabel()
    label.font = .init(name: Font.medium.rawValue, size: 12)
    label.textColor = .idorm_gray_400
    label.numberOfLines = 0
    label.text = "더미텍스트더미텍스트더미텍스트더미텍스트더미텍스트더미텍스트더미텍스트더미텍스트더미텍스트더미텍스트더미텍스트더미텍스트더미텍스트더미텍스트더미텍스트더미텍스트더미텍스트더미텍스트더미텍스트더미텍스트더미텍스트더미텍스트더미텍스트더미텍스트더미텍스트더미텍스트"
    
    return label
  }()
  
  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.itemSize = CGSize(width: 120, height: 120)
    layout.minimumInteritemSpacing = 8
    layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.register(CommunityDetailHeaderCollectionViewCell.self, forCellWithReuseIdentifier: CommunityDetailHeaderCollectionViewCell.identifier)
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.dataSource = self
    collectionView.delegate = self
    
    return collectionView
  }()
  
  lazy var likeButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitle("공감하기", for: .normal)
    button.setTitleColor(UIColor.black, for: .normal)
    button.backgroundColor = .idorm_gray_100
    button.layer.cornerRadius = 4
    button.layer.masksToBounds = true
    button.titleLabel?.font = .init(name: Font.medium.rawValue, size: 10)
    button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
    
    return button
  }()
  
  lazy var orderOfRegisterationButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitle("등록순", for: .normal)
    button.setTitleColor(UIColor.black, for: .selected)
    button.setTitleColor(UIColor.idorm_gray_300, for: .normal)
    button.titleLabel?.font = .init(name: Font.medium.rawValue, size: 10)
    
    return button
  }()
  
  lazy var theLastestOrderButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitle("최신순", for: .normal)
    button.setTitleColor(UIColor.black, for: .selected)
    button.setTitleColor(UIColor.idorm_gray_300, for: .normal)
    button.titleLabel?.font = .init(name: Font.medium.rawValue, size: 10)
    
    return button
  }()

  // MARK: - Helpers
  func configureUI() {
    let nickNameStack = UIStackView(arrangedSubviews: [ nicknameLabel, timeLabel ])
    nickNameStack.axis = .vertical
    nickNameStack.alignment = .leading
    
    let pictureStack = UIStackView(arrangedSubviews: [ pictureImg, pictureCountLabel ])
    pictureStack.axis = .horizontal
    pictureStack.spacing = 5
    
    let likeStack = UIStackView(arrangedSubviews: [ likeImg, likeCountLabel ])
    likeStack.axis = .horizontal
    likeStack.spacing = 5

    let messageStack = UIStackView(arrangedSubviews: [ messageImg, messageCountLabel ])
    messageStack.axis = .horizontal
    messageStack.spacing = 5
    
    [ myImg, nickNameStack, titleLabel, contentsLabel, collectionView, separatorLine, likeStack, messageStack, pictureStack, likeButton, separatorLine2, orderOfRegisterationButton, theLastestOrderButton ]
      .forEach { addSubview($0) }

    myImg.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(16)
      make.leading.equalToSuperview().inset(24)
      make.width.height.equalTo(42)
    }
    
    nickNameStack.snp.makeConstraints { make in
      make.centerY.equalTo(myImg)
      make.leading.equalTo(myImg.snp.trailing).offset(10)
    }
    
    titleLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(myImg.snp.bottom).offset(12)
    }
    
    contentsLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(titleLabel.snp.bottom).offset(12)
    }
    
    collectionView.snp.makeConstraints { make in
      make.top.equalTo(contentsLabel.snp.bottom).offset(24)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(120)
    }
    
    separatorLine.snp.makeConstraints { make in
      make.top.equalTo(collectionView.snp.bottom).offset(24)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(1)
    }
    
    likeStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(separatorLine.snp.bottom).offset(16)
    }
    
    messageStack.snp.makeConstraints { make in
      make.leading.equalTo(likeStack.snp.trailing).offset(8)
      make.centerY.equalTo(likeStack)
    }
    
    pictureStack.snp.makeConstraints { make in
      make.leading.equalTo(messageStack.snp.trailing).offset(8)
      make.centerY.equalTo(likeStack)
    }
    
    separatorLine2.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(likeStack.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    likeButton.snp.makeConstraints { make in
      make.centerY.equalTo(likeStack)
      make.trailing.equalToSuperview().inset(39)
    }
    
    orderOfRegisterationButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(separatorLine2.snp.bottom).offset(8)
    }
    
    theLastestOrderButton.snp.makeConstraints { make in
      make.leading.equalTo(orderOfRegisterationButton.snp.trailing).offset(12)
      make.centerY.equalTo(orderOfRegisterationButton)
      make.bottom.equalToSuperview().inset(8)
    }
  }
  
  func test() {
    collectionView.snp.removeConstraints()
    separatorLine.snp.removeConstraints()
    
    separatorLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(contentsLabel.snp.bottom).offset(24)
      make.height.equalTo(1)
    }
  }
}

extension CommunityDetailTableHeaderView: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommunityDetailHeaderCollectionViewCell.identifier, for: indexPath) as? CommunityDetailHeaderCollectionViewCell else { return UICollectionViewCell() }
    cell.configureUI()
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 10
  }
}
