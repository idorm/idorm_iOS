//
//  CommunityPostContentCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/20.
//

import UIKit

import SnapKit
import Kingfisher

/// 게시글의 유저의 정보 및 게시글 내용이 들어가는 `UICollectionViewCell`
final class CommunityPostContentCell: UICollectionViewCell, BaseView {
  
  // MARK: - UI Components
  
  /// 유저의 프로필 사진이 들어가는 `UIImageView`
  private let profileImageView: UIImageView = {
    let iv = UIImageView()
    iv.image = .iDormImage(.human)
    iv.layer.cornerRadius = 8.0
    iv.layer.masksToBounds = true
    return iv
  }()
  
  /// 유저의 닉네임이 들어가는 `UILabel`
  private let nicknameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = .iDormFont(.medium, size: 14)
    return label
  }()
  
  /// 게시글이 작성된 시간을 알려주는 `UILabel`
  private let timeLabel: UILabel = {
    let label = UILabel()
    label.textColor = .iDormColor(.iDormGray300)
    label.font = .iDormFont(.medium, size: 12)
    return label
  }()

  /// `nicknameLabel`과 `timeLabel`의 수직 성분의 `UIStackView`
  private lazy var profileStackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [
      nicknameLabel,
      timeLabel
    ])
    stack.axis = .vertical
    return stack
  }()
  
  /// 게시글의 제목 `UILabel`
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.medium, size: 16)
    label.textColor = .black
    label.numberOfLines = 2
    return label
  }()
  
  /// 게시글의 내용 `UILabel`
  private let contentsLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.regular, size: 14)
    label.textColor = .black
    label.numberOfLines = 0
    return label
  }()
  
//  private lazy var sympathyButton: idormCommunityButton = {
//    let btn = idormCommunityButton("공감하기")
//    btn.configurationUpdateHandler = {
//      switch $0.state {
//      case .selected:
//        $0.configuration?.baseBackgroundColor = .idorm_blue
//        $0.configuration?.baseForegroundColor = .white
//      case .normal:
//        $0.configuration?.baseBackgroundColor = .idorm_gray_100
//        $0.configuration?.baseForegroundColor = .black
//      default:
//        break
//      }
//    }
//    return btn
//  }()
  
//  private let likeImageView = UIImageView(image: UIImage(named: "thumbsup_medium"))
//  private lazy var likeCountLabel = countLabel()
//  private let commentImageView = UIImageView(image: UIImage(named: "speechBubble_double_medium"))
//  private lazy var commentCountLabel = countLabel()
//  private let pictureImageView = UIImageView(image: UIImage(named: "picture_medium"))
//  private lazy var pictureCountLabel = countLabel()
//  private let separatorLine = UIFactory.view(.idorm_gray_200)
//  private let separatorLine2 = UIFactory.view(.idorm_gray_200)
//  lazy var orderByLastestButton = orderButton("최신순")
//  lazy var orderByRegisterationButton = orderButton("등록순")
  
  // MARK: - PROPERTIES
  
  var sympathyButtonCompletion: ((Bool) -> Void)?
  var optionButtonCompletion: (() -> Void)?
  var photoCompletion: ((Int) -> Void)?
//  private var post: CommunityResponseModel.Post!
//  private var isSympathy: Bool = false
//  private var bottomConstraints: Constraint?
//  private var photoConstarints: Constraint?
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  func setupStyles() {}
  
  func setupLayouts() {
    [
      self.profileImageView,
      self.profileStackView,
      self.titleLabel,
      self.contentsLabel
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.profileImageView.snp.makeConstraints { make in
      make.top.leading.equalToSuperview()
      make.size.equalTo(42.0)
    }
    
    self.profileStackView.snp.makeConstraints { make in
      make.centerY.equalTo(self.profileImageView)
      make.leading.equalTo(self.profileImageView.snp.trailing).offset(10.0)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview()
      make.top.equalTo(self.profileImageView.snp.bottom).offset(12.0)
    }
    
    self.contentsLabel.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview()
      make.top.equalTo(self.titleLabel.snp.bottom).offset(12.0)
      make.bottom.equalToSuperview().inset(24.0)
    }
  }
  
  private func updateUI() {
//    if self.post.commentsCount == 0 {
//      self.bottomConstraints?.update(inset: 0)
//      self.orderByLastestButton.isHidden = true
//      self.orderByRegisterationButton.isHidden = true
//    } else {
//      self.bottomConstraints?.update(inset: 40)
//      self.orderByLastestButton.isHidden = false
//      self.orderByRegisterationButton.isHidden = false
//    }
//    
//    if self.isSympathy {
//      self.likeImageView.tintColor = .idorm_blue
//      self.likeCountLabel.textColor = .idorm_blue
//      self.sympathyButton.isSelected = true
//    } else {
//      self.likeImageView.tintColor = .idorm_gray_300
//      self.likeCountLabel.textColor = .idorm_gray_300
//      self.sympathyButton.isSelected = false
//    }
//    
//    if self.post.postPhotos.isEmpty {
//      self.photoCollectionView.isHidden = true
//      self.photoConstarints?.update(offset: 24)
//    } else {
//      self.photoCollectionView.isHidden = false
//      self.photoConstarints?.update(offset: 168)
//    }
  }
  
  func injectData(_ post: CommunityResponseModel.Post, isSympathy: Bool) {
//    self.post = post
//    self.isSympathy = isSympathy
//    self.titleLabel.text = post.title
//    self.contentsLabel.text = post.content
//    self.nicknameLabel.text = post.nickname ?? "익명"
//    self.timeLabel.text = TimeUtils.detailPost(post.createdAt)
//    self.likeCountLabel.text = "\(post.likesCount)"
//    self.commentCountLabel.text = "\(post.commentsCount)"
//    self.pictureCountLabel.text = "\(post.imagesCount)"
//    
//    if !post.isAnonymous,
//       let profileUrl = post.profileUrl {
//      ProfileImageView.kf.setImage(with: URL(string: profileUrl))
//    }
//    
//    self.updateUI()
//    self.photoCollectionView.reloadData()
  }
}
