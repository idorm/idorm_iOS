//
//  MyCommentsCollectionVIewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/30.
//

import SnapKit
import UIKit
import RxSwift
import RxCocoa

class MyCommentsCollectionViewCell: UICollectionViewCell {
  // MARK: - Properties
  lazy var myImg: UIImageView = {
    let iv = UIImageView()
    iv.backgroundColor = .idorm_gray_300
    iv.layer.cornerRadius = 8
    iv.layer.masksToBounds = true
    
    return iv
  }()
  
  lazy var nicknameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = .init(name: Font.medium.rawValue, size: 14)
    label.text = "닉네임닉네임닉네임"
    
    return label
  }()
  
  lazy var timeLabel: UILabel = {
    let label = UILabel()
    label.textColor = .idorm_gray_300
    label.font = .init(name: Font.medium.rawValue, size: 10)
    label.text = "1시간 전"
    
    return label
  }()
  
  lazy var contentsLabel: UILabel = {
    let label = UILabel()
    label.textColor = .idorm_gray_400
    label.font = .init(name: Font.medium.rawValue, size: 12)
    label.numberOfLines = 0
    label.text = "댓글 내용 댓글 내용 댓글 내용 댓글 내용 댓글 내용 댓글 내용 댓글 내용"
    
    return label
  }()
  
  lazy var replyButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitle("본문 보기", for: .normal)
    button.setTitleColor(UIColor.black, for: .normal)
    button.backgroundColor = .idorm_gray_100
    button.titleLabel?.font = .init(name: Font.medium.rawValue, size: 10)
    button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
    
    return button
  }()
  
  static let identifier = "MyCommentsCollectionViewCell"
  
  // MARK: - LifeCycle
  
  // MARK: - Helpers
  func configureUI() {
    contentView.backgroundColor = .white
    
    let nickNameStack = UIStackView(arrangedSubviews: [ nicknameLabel, timeLabel ])
    nickNameStack.axis = .vertical
    nickNameStack.alignment = .leading

    [ myImg, nickNameStack, contentsLabel, replyButton ]
      .forEach { contentView.addSubview($0) }
    
    myImg.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalToSuperview().inset(16)
      make.width.height.equalTo(42)
    }
    
    nickNameStack.snp.makeConstraints { make in
      make.top.equalTo(myImg.snp.top)
      make.leading.equalTo(myImg.snp.trailing).offset(10)
    }
    
    contentsLabel.snp.makeConstraints { make in
      make.leading.equalTo(nickNameStack.snp.leading)
      make.top.equalTo(nickNameStack.snp.bottom).offset(8)
      make.trailing.equalToSuperview().inset(24)
    }
    
    replyButton.snp.makeConstraints { make in
      make.top.equalTo(contentsLabel.snp.bottom).offset(10)
      make.leading.equalTo(nickNameStack.snp.leading)
      make.bottom.equalToSuperview().inset(16)
    }
  }
}
