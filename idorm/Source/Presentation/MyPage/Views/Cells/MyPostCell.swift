//
//  MyPostCell.swift
//  idorm
//
//  Created by 김응철 on 2023/04/30.
//

import UIKit

import SnapKit

final class MyPostCell: UITableViewCell, BaseView {
  
  // MARK: - Properties
  
  static let identifier = "MyPostCell"
  
  private let titleLb: UILabel = {
    let lb = UILabel()
    lb.font = .init(name: IdormFont_deprecated.medium.rawValue, size: 14)
    lb.textColor = .black
    
    return lb
  }()
  
  private let contentLb: UILabel = {
    let lb = UILabel()
    lb.font = .init(name: IdormFont_deprecated.medium.rawValue, size: 12)
    lb.textColor = .idorm_gray_400
    return lb
  }()
  
  private let nicknameLb: UILabel = {
    let lb = UILabel()
    lb.font = .init(name: IdormFont_deprecated.regular.rawValue, size: 12)
    lb.textColor = .idorm_gray_300
    return lb
  }()
  
  private let timeLb: UILabel = {
    let lb = UILabel()
    lb.font = .init(name: IdormFont_deprecated.medium.rawValue, size: 12)
    lb.textColor = .idorm_gray_300
    return lb
  }()
  
  private let dotLb: UILabel = {
    let lb = UILabel()
    lb.font = .init(name: IdormFont_deprecated.regular.rawValue, size: 12)
    lb.text = "∙"
    lb.textColor = .idorm_gray_300
    return lb
  }()
  
  private let separatorLine: UIView = {
    let view = UIView()
    view.backgroundColor = .idorm_gray_200
    
    return view
  }()
  
  private let likeCountLb: UILabel = {
    let lb = UILabel()
    lb.textColor = .idorm_gray_300
    lb.font = .init(name: IdormFont_deprecated.regular.rawValue, size: 12)
    
    return lb
  }()
  
  private let commentsCountLb: UILabel = {
    let lb = UILabel()
    lb.textColor = .idorm_gray_300
    lb.font = .init(name: IdormFont_deprecated.regular.rawValue, size: 12)
    return lb
  }()

  private let pictureCountLb: UILabel = {
    let lb = UILabel()
    lb.textColor = .idorm_gray_300
    lb.font = .init(name: IdormFont_deprecated.regular.rawValue, size: 12)
    return lb
  }()
  
  private let lineView: UIView = {
    let view = UIView()
    view.backgroundColor = .idorm_gray_100
    return view
  }()
  
  private let likeIv = UIImageView(image: UIImage(named: "thumbsup_small"))
  private let commentIv = UIImageView(image: UIImage(named: "speechBubble_double_small"))
  private let pictureIv = UIImageView(image: UIImage(named: "picture_small"))
  
  // MARK: - LifeCycle
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupStyles()
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup
  
  func setupStyles() {
    contentView.backgroundColor = .white
  }
  
  func setupLayouts() {
    [
      titleLb,
      contentLb,
      nicknameLb,
      timeLb,
      dotLb,
      separatorLine,
      likeIv,likeCountLb,
      commentIv,commentsCountLb,
      pictureIv,pictureCountLb,
      lineView
    ].forEach {
      contentView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    titleLb.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalToSuperview().inset(12)
    }
    
    contentLb.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(titleLb.snp.bottom).offset(4)
    }
    
    nicknameLb.snp.makeConstraints { make in
      make.top.equalTo(contentLb.snp.bottom).offset(12)
      make.leading.equalToSuperview().inset(24)
    }
    
    dotLb.snp.makeConstraints { make in
      make.leading.equalTo(nicknameLb.snp.trailing).offset(4)
      make.centerY.equalTo(nicknameLb)
    }
    
    timeLb.snp.makeConstraints { make in
      make.leading.equalTo(dotLb.snp.trailing).offset(4)
      make.centerY.equalTo(nicknameLb)
    }
    
    separatorLine.snp.makeConstraints { make in
      make.top.equalTo(nicknameLb.snp.bottom).offset(14)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(1)
    }
    
    likeIv.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(separatorLine.snp.bottom).offset(12)
    }
    
    likeCountLb.snp.makeConstraints { make in
      make.centerY.equalTo(likeIv)
      make.leading.equalTo(likeIv.snp.trailing).offset(4)
    }
    
    commentIv.snp.makeConstraints { make in
      make.centerY.equalTo(likeIv)
      make.leading.equalTo(likeCountLb.snp.trailing).offset(12)
    }
    
    commentsCountLb.snp.makeConstraints { make in
      make.leading.equalTo(commentIv.snp.trailing).offset(4)
      make.centerY.equalTo(likeIv)
    }
    
    pictureIv.snp.makeConstraints { make in
      make.leading.equalTo(commentsCountLb.snp.trailing).offset(12)
      make.centerY.equalTo(likeIv)
    }
    
    pictureCountLb.snp.makeConstraints { make in
      make.leading.equalTo(pictureIv.snp.trailing).offset(4)
      make.centerY.equalTo(likeIv)
    }
    
    lineView.snp.makeConstraints { make in
      make.bottom.leading.trailing.equalToSuperview()
      make.height.equalTo(6)
    }
  }
  
  // MARK: - Helpers
  
  func injectData(_ post: CommunityResponseModel.Posts) {
    titleLb.text = post.title
    contentLb.text = post.content
    nicknameLb.text = post.nickname
    likeCountLb.text = "\(post.likesCount)"
    pictureCountLb.text = "\(post.imagesCount)"
    commentsCountLb.text = "\(post.commentsCount)"
    timeLb.text = TimeUtils.postList(post.createdAt)

    if post.imagesCount == 0 {
      pictureCountLb.isHidden = true
      pictureIv.isHidden = true
    } else {
      pictureCountLb.isHidden = false
      pictureIv.isHidden = false
    }
  }
}
