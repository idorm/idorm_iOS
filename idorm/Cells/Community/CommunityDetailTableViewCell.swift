//
//  CommunityDetailTableViewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/21.
//

import UIKit
import SnapKit

protocol CommunityDetailTableViewCellDelegate: AnyObject {
  func didTapCommentOptionButton()
}

class CommunityDetailTableViewCell: UITableViewCell {
  // MARK: - Properties
  static let identifier = "CommunityDetailTableViewCell"
  weak var delegate: CommunityDetailTableViewCellDelegate?
  
  lazy var myImg: UIImageView = {
    let iv = UIImageView()
    iv.backgroundColor = .grey_custom
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
    label.textColor = .grey_custom
    label.font = .init(name: Font.medium.rawValue, size: 10)
    label.text = "1시간 전"
    
    return label
  }()
  
  lazy var optionButton: UIButton = {
    let btn = UIButton(type: .custom)
    btn.setImage(UIImage(named: "option"), for: .normal)
    btn.addTarget(self, action: #selector(didTapCommentOptionButton), for: .touchUpInside)
    
    return btn
  }()
  
  lazy var contentsLabel: UILabel = {
    let label = UILabel()
    label.textColor = .darkgrey_custom
    label.font = .init(name: Font.medium.rawValue, size: 12)
    label.numberOfLines = 0
    label.text = "댓글 내용 댓글 내용 댓글 내용 댓글 내용 댓글 내용 댓글 내용 댓글 내용"
    
    return label
  }()
  
  lazy var replyButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitle("답글 쓰기", for: .normal)
    button.setTitleColor(UIColor.black, for: .normal)
    button.backgroundColor = .blue_white
    button.titleLabel?.font = .init(name: Font.medium.rawValue, size: 10)
    button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
    
    return button
  }()
  
  // MARK: - LifeCycle
  
  // MARK: - Selectors
  @objc private func didTapCommentOptionButton() {
    delegate?.didTapCommentOptionButton()
  }
  
  // MARK: - Helpers
  func configureUI() {
    contentView.backgroundColor = .white
    
    let nickNameStack = UIStackView(arrangedSubviews: [ nicknameLabel, timeLabel ])
    nickNameStack.axis = .vertical
    nickNameStack.alignment = .leading

    [ myImg, nickNameStack, optionButton, contentsLabel, replyButton ]
      .forEach { contentView.addSubview($0) }
    
    myImg.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalToSuperview().inset(16)
      make.width.height.equalTo(42)
    }
    
    nickNameStack.snp.makeConstraints { make in
      make.top.equalTo(myImg.snp.top)
      make.leading.equalTo(myImg.snp.trailing).offset(10)
      make.trailing.equalTo(optionButton.snp.leading).offset(-10)
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
    
    optionButton.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(16)
      make.trailing.equalToSuperview().inset(14)
    }
  }
}
