//
//  PostDetailHeader.swift
//  idorm
//
//  Created by 김응철 on 2022/07/20.
//

import UIKit

import SnapKit

final class DetailPostHeaderView: UITableViewHeaderFooterView {
  
  // MARK: - UI
  
  static let identifier = "PostDetailHeader"
  
  private let myProfileImageView: UIImageView = {
    let iv = UIImageView()
    iv.backgroundColor = .idorm_gray_300
    iv.layer.cornerRadius = 8
    iv.layer.masksToBounds = true
    
    return iv
  }()
  
  private let nicknameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = .idormFont(.medium, size: 14)
    
    return label
  }()
  
  private lazy var profileStack: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [
      nicknameLabel,
      timeLabel
    ])
    stack.axis = .vertical
    
    return stack
  }()
  
  private let timeLabel: UILabel = {
    let label = UILabel()
    label.textColor = .idorm_gray_300
    label.font = .idormFont(.medium, size: 12)
    
    return label
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .idormFont(.medium, size: 16)
    label.textColor = .black
    label.numberOfLines = 2
    
    return label
  }()
  
  private let contentsLabel: UILabel = {
    let label = UILabel()
    label.font = .idormFont(.regular, size: 14)
    label.textColor = .black
    label.numberOfLines = 0
    
    return label
  }()
  
  private lazy var photoCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.itemSize = CGSize(width: 120, height: 120)
    layout.minimumInteritemSpacing = 8
    layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.register(
      DetailPostPhotoCell.self,
      forCellWithReuseIdentifier: DetailPostPhotoCell.identifier
    )
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.dataSource = self
    collectionView.delegate = self

    return collectionView
  }()
  
  private lazy var sympathyButton: idormCommunityButton = {
    let btn = idormCommunityButton("공감하기")
    btn.configurationUpdateHandler = {
      switch $0.state {
      case .selected:
        $0.configuration?.baseBackgroundColor = .idorm_blue
        $0.configuration?.baseForegroundColor = .white
      case .normal:
        $0.configuration?.baseBackgroundColor = .idorm_gray_100
        $0.configuration?.baseForegroundColor = .black
      default:
        break
      }
    }
    
    return btn
  }()
  
  private let likeImageView = UIImageView(image: UIImage(named: "thumbsup_medium")?.withRenderingMode(.alwaysTemplate))
  private lazy var likeCountLabel = countLabel()
  private let commentImageView = UIImageView(image: UIImage(named: "speechBubble_double_medium"))
  private lazy var commentCountLabel = countLabel()
  private let pictureImageView = UIImageView(image: UIImage(named: "picture_medium"))
  private lazy var pictureCountLabel = countLabel()
  private let separatorLine = UIFactory.view(.idorm_gray_200)
  private let separatorLine2 = UIFactory.view(.idorm_gray_200)
  lazy var orderByLastestButton = orderButton("최신순")
  lazy var orderByRegisterationButton = orderButton("등록순")
  
  // MARK: - PROPERTIES
  
  var sympathyButtonCompletion: ((Bool) -> Void)?
  var optionButtonCompletion: (() -> Void)?
  var photoCompletion: ((Int) -> Void)?
  private var post: CommunityResponseModel.Post!
  private var isSympathy: Bool = false
  private var bottomConstraints: Constraint?
  private var photoConstarints: Constraint?
  
  // MARK: - INITIALIZER
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.setupSelectors()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Helpers
  
  private func countLabel() -> UILabel {
    let lb = UILabel()
    lb.textColor = .idorm_gray_300
    lb.font = .idormFont(.regular, size: 12)
    return lb
  }
  
  private func orderButton(_ title: String) -> UIButton {
    let btn = UIButton()
    btn.setTitle(title, for: .normal)
    btn.setTitleColor(.black, for: .selected)
    btn.setTitleColor(.idorm_gray_300, for: .normal)
    btn.titleLabel?.font = .idormFont(.regular, size: 12)
    
    return btn
  }
  
  private func updateUI() {
    if self.post.commentsCount == 0 {
      self.bottomConstraints?.update(inset: 0)
      self.orderByLastestButton.isHidden = true
      self.orderByRegisterationButton.isHidden = true
    } else {
      self.bottomConstraints?.update(inset: 40)
      self.orderByLastestButton.isHidden = false
      self.orderByRegisterationButton.isHidden = false
    }
    
    if self.isSympathy {
      self.likeImageView.tintColor = .idorm_blue
      self.likeCountLabel.textColor = .idorm_blue
      self.sympathyButton.isSelected = true
    } else {
      self.likeImageView.tintColor = .idorm_gray_300
      self.likeCountLabel.textColor = .idorm_gray_300
      self.sympathyButton.isSelected = false
    }
    
    if self.post.postPhotos.isEmpty {
      self.photoCollectionView.isHidden = true
      self.photoConstarints?.update(offset: 24)
    } else {
      self.photoCollectionView.isHidden = false
      self.photoConstarints?.update(offset: 168)
    }
  }
  
  func injectData(_ post: CommunityResponseModel.Post, isSympathy: Bool) {
    self.post = post
    self.isSympathy = isSympathy
    self.titleLabel.text = post.title
    self.contentsLabel.text = post.content
    self.nicknameLabel.text = post.nickname?.isAnonymous
    self.timeLabel.text = TimeUtils.detailPost(post.createdAt)
    self.likeCountLabel.text = "\(post.likesCount)"
    self.commentCountLabel.text = "\(post.commentsCount)"
    self.pictureCountLabel.text = "\(post.imagesCount)"
    self.updateUI()
    self.photoCollectionView.reloadData()
  }
  
  // MARK: - SELECTORS
  
  @objc
  private func sympathyButtonDidTap() {
    self.sympathyButtonCompletion?(self.sympathyButton.isSelected)
  }
}

// MARK: - Setup

extension DetailPostHeaderView: BaseView {
  
  private func setupSelectors() {
    self.sympathyButton.addTarget(self, action: #selector(sympathyButtonDidTap), for: .touchUpInside)
  }
  
  func setupStyles() {
    self.orderByRegisterationButton.isSelected = true
  }
  
  func setupLayouts() {
    [
      self.myProfileImageView,
      self.profileStack,
      self.titleLabel,
      self.contentsLabel,
      self.separatorLine,
      self.likeImageView, self.likeCountLabel,
      self.commentImageView, self.commentCountLabel,
      self.pictureImageView, self.pictureCountLabel,
      self.separatorLine2,
      self.sympathyButton,
      self.orderByRegisterationButton, self.orderByLastestButton,
      self.photoCollectionView
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.myProfileImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalToSuperview().inset(16)
      make.width.height.equalTo(42)
    }
    
    self.profileStack.snp.makeConstraints { make in
      make.leading.equalTo(self.myProfileImageView.snp.trailing).offset(10)
      make.centerY.equalTo(self.myProfileImageView)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(myProfileImageView.snp.bottom).offset(12)
    }
    
    self.contentsLabel.snp.makeConstraints { make in
      make.top.equalTo(self.titleLabel.snp.bottom).offset(12)
      make.leading.trailing.equalToSuperview().inset(24)
    }
    
    self.photoCollectionView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(self.contentsLabel.snp.bottom).offset(24)
      make.height.equalTo(120)
    }
    
    self.separatorLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      self.photoConstarints = make.top.equalTo(self.contentsLabel.snp.bottom).offset(24).constraint
      make.height.equalTo(1)
    }
    
    self.likeImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25.5)
      make.top.equalTo(separatorLine.snp.bottom).offset(25.5)
    }
    
    self.likeCountLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.likeImageView.snp.trailing).offset(5.5)
      make.centerY.equalTo(self.likeImageView)
    }
    
    self.commentImageView.snp.makeConstraints { make in
      make.leading.equalTo(self.likeCountLabel.snp.trailing).offset(13.5)
      make.centerY.equalTo(self.likeImageView)
    }
    
    self.commentCountLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.commentImageView.snp.trailing).offset(5.5)
      make.centerY.equalTo(self.likeImageView)
    }
    
    self.pictureImageView.snp.makeConstraints { make in
      make.leading.equalTo(self.commentCountLabel.snp.trailing).offset(13.5)
      make.centerY.equalTo(self.likeImageView)
    }
    
    self.pictureCountLabel.snp.makeConstraints { make in
      make.leading.equalTo(pictureImageView.snp.trailing).offset(5.5)
      make.centerY.equalTo(likeImageView)
    }
    
    self.sympathyButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(24)
      make.centerY.equalTo(likeImageView)
    }
    
    self.separatorLine2.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(self.sympathyButton.snp.bottom).offset(12)
      self.bottomConstraints = make.bottom.equalToSuperview().inset(40).constraint
      make.height.equalTo(1)
    }
    
    self.orderByRegisterationButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(separatorLine2.snp.bottom).offset(8)
    }
    
    self.orderByLastestButton.snp.makeConstraints { make in
      make.leading.equalTo(orderByRegisterationButton.snp.trailing).offset(12)
      make.centerY.equalTo(orderByRegisterationButton)
    }
  }
}

// MARK: - SETUP COLLECTIONVIEW

extension DetailPostHeaderView: UICollectionViewDataSource, UICollectionViewDelegate {
  
  // 셀 생성
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: DetailPostPhotoCell.identifier,
      for: indexPath
    ) as? DetailPostPhotoCell else {
      return UICollectionViewCell()
    }
    cell.injectData(self.post.postPhotos[indexPath.row].photoUrl)
    
    return cell
  }

  // 셀 갯수
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return self.post.postPhotos.count
  }
  
  // 셀 터치
  func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    self.photoCompletion?(indexPath.row)
  }
}
