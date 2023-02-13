//
//  PostDetailHeader.swift
//  idorm
//
//  Created by 김응철 on 2022/07/20.
//

import UIKit

import SnapKit

final class PostDetailHeader: UIView {
  
  // MARK: - Properties
  
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
  
  lazy var photoCollectionView: UICollectionView = {
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
  
  lazy var sympathyButton: idormCommunityButton = {
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
    btn.addTarget(self, action: #selector(didTapSympathyButton), for: .touchUpInside)
    
    return btn
  }()
  
  let likeImageView = UIImageView(image: UIImage(named: "thumbsup_medium")?.withRenderingMode(.alwaysTemplate))
  lazy var likeCountLabel = countLabel()
  private let commentImageView = UIImageView(image: UIImage(named: "speechBubble_double_medium"))
  private lazy var commentCountLabel = countLabel()
  private let pictureImageView = UIImageView(image: UIImage(named: "picture_medium"))
  private lazy var pictureCountLabel = countLabel()
  private let separatorLine = UIView()
  private let separatorLine2 = UIView()
  lazy var orderByLastestButton = orderButton("최신순")
  lazy var orderByRegisterationButton = orderButton("등록순")
  var sympathyButtonCompletion: ((Bool) -> Void)?
  
  private var photoUrls: [String] = []
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    setupStyles()
    setupLayouts()
    setupConstraints()
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
  
  func orderButton(_ title: String) -> UIButton {
    let btn = UIButton()
    btn.setTitle(title, for: .normal)
    btn.setTitleColor(.black, for: .selected)
    btn.setTitleColor(.idorm_gray_300, for: .normal)
    btn.titleLabel?.font = .idormFont(.regular, size: 12)
    
    return btn
  }
  
  @objc
  private func didTapSympathyButton() {
    self.sympathyButtonCompletion?(sympathyButton.isSelected)
  }
}

// MARK: - Setup

extension PostDetailHeader: BaseView {
  func injectData(_ post: CommunityResponseModel.Post, isSympathy: Bool) {
    self.photoUrls = post.photoUrls
    
    if photoUrls.isEmpty {
      self.photoCollectionView.isHidden = true

      self.separatorLine.snp.updateConstraints { make in
        make.top.equalTo(self.photoCollectionView.snp.bottom).offset(-120)
      }
      
    } else {
      self.photoCollectionView.isHidden = false
      
      self.separatorLine.snp.updateConstraints { make in
        make.top.equalTo(self.photoCollectionView.snp.bottom).offset(24)
      }
    }
    
    if isSympathy {
      likeImageView.tintColor = .idorm_blue
      likeCountLabel.textColor = .idorm_blue
      sympathyButton.isSelected = true
    } else {
      likeImageView.tintColor = .idorm_gray_300
      likeCountLabel.textColor = .idorm_gray_300
      sympathyButton.isSelected = false
    }
    
    titleLabel.text = post.title
    contentsLabel.text = post.content
    nicknameLabel.text = post.nickname?.isAnonymous
    timeLabel.text = TimeUtils.detailPost(post.createdAt)
    likeCountLabel.text = "\(post.likesCount)"
    commentCountLabel.text = "\(post.commentsCount)"
    pictureCountLabel.text = "\(post.imagesCount)"
    
    switch post.comments.count {
    case 0:
      [
        orderByLastestButton,
        orderByRegisterationButton
      ].forEach {
        $0.isHidden = true
      }
      
      orderByLastestButton.snp.updateConstraints { make in
        make.bottom.equalToSuperview().inset(-38)
      }
      
    default:
      [
        orderByLastestButton,
        orderByRegisterationButton
      ].forEach {
        $0.isHidden = false
      }

      orderByLastestButton.snp.updateConstraints { make in
        make.bottom.equalToSuperview().inset(8)
      }
    }
    
    self.photoCollectionView.reloadData()
  }
  
  func setupStyles() {
    [
      separatorLine,
      separatorLine2
    ].forEach {
      $0.backgroundColor = .idorm_gray_200
    }
    orderByRegisterationButton.isSelected = true
  }
  
  func setupLayouts() {
    [
      myProfileImageView,
      profileStack,
      titleLabel,
      contentsLabel,
      separatorLine,
      likeImageView, likeCountLabel,
      commentImageView, commentCountLabel,
      pictureImageView, pictureCountLabel,
      separatorLine2,
      sympathyButton,
      orderByRegisterationButton, orderByLastestButton,
      photoCollectionView
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    myProfileImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalToSuperview().inset(16)
      make.width.height.equalTo(42)
    }
    
    profileStack.snp.makeConstraints { make in
      make.leading.equalTo(myProfileImageView.snp.trailing).offset(10)
      make.centerY.equalTo(myProfileImageView)
    }
    
    titleLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(myProfileImageView.snp.bottom).offset(12)
    }
    
    contentsLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(12)
      make.leading.trailing.equalToSuperview().inset(24)
    }
    
    self.photoCollectionView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(contentsLabel.snp.bottom).offset(24)
      make.height.equalTo(120)
    }
    
    separatorLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(photoCollectionView.snp.bottom).offset(24)
      make.height.equalTo(1)
    }
    
    likeImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25.5)
      make.top.equalTo(separatorLine.snp.bottom).offset(25.5)
    }
    
    likeCountLabel.snp.makeConstraints { make in
      make.leading.equalTo(likeImageView.snp.trailing).offset(5.5)
      make.centerY.equalTo(likeImageView)
    }
    
    commentImageView.snp.makeConstraints { make in
      make.leading.equalTo(likeCountLabel.snp.trailing).offset(13.5)
      make.centerY.equalTo(likeImageView)
    }
    
    commentCountLabel.snp.makeConstraints { make in
      make.leading.equalTo(commentImageView.snp.trailing).offset(5.5)
      make.centerY.equalTo(likeImageView)
    }
    
    pictureImageView.snp.makeConstraints { make in
      make.leading.equalTo(commentCountLabel.snp.trailing).offset(13.5)
      make.centerY.equalTo(likeImageView)
    }
    
    pictureCountLabel.snp.makeConstraints { make in
      make.leading.equalTo(pictureImageView.snp.trailing).offset(5.5)
      make.centerY.equalTo(likeImageView)
    }
    
    sympathyButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(24)
      make.centerY.equalTo(likeImageView)
    }
    
    separatorLine2.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(sympathyButton.snp.bottom).offset(12)
      make.height.equalTo(1)
    }
    
    orderByRegisterationButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(separatorLine2.snp.bottom).offset(8)
    }
    
    orderByLastestButton.snp.makeConstraints { make in
      make.leading.equalTo(orderByRegisterationButton.snp.trailing).offset(12)
      make.centerY.equalTo(orderByRegisterationButton)
      make.bottom.equalToSuperview().inset(8)
    }
  }
}

// MARK: - SETUP COLLECTIONVIEW

extension PostDetailHeader: UICollectionViewDataSource, UICollectionViewDelegate {
  
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
    cell.injectData(photoUrls[indexPath.row])
    
    return cell
  }

  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return photoUrls.count
  }
}
