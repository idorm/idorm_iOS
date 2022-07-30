//
//  MypageViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/17.
//

import UIKit
import SnapKit

class MyPageViewController: UIViewController {
  // MARK: - Properties
  lazy var topRoundedView: UIView = {
    let view = UIView()
    view.backgroundColor = .idorm_blue
    view.layer.cornerRadius = 24
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOffset = CGSize(width: 0, height: 5)
    view.layer.shadowOpacity = 0.1
    
    return view
  }()
  
  lazy var matchingContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOffset = CGSize(width: 0, height: 3)
    view.layer.shadowOpacity = 0.1
    
    return view
  }()
  
  lazy var communityContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOffset = CGSize(width: 0, height: 3)
    view.layer.shadowOpacity = 0.1
    
    return view
  }()
  
  lazy var updateMyProfileImageButton: UIButton = {
    var config = UIButton.Configuration.plain()
    config.image = UIImage(systemName: "chevron.right")
    config.imagePadding = 4
    config.imagePlacement = .trailing
    config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration.init(pointSize: 10)
    var container = AttributeContainer()
    container.foregroundColor = UIColor.white
    container.font = .init(name: Font.medium.rawValue, size: 14)
    config.attributedTitle = AttributedString("내 정보 수정", attributes: container)
    config.baseForegroundColor = .white
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    let button = UIButton(configuration: config)
    
    return button
  }()
  
  lazy var matchingImageManagementButton = createMatchingButton(imageName: "picture(MyPage)", title: "매칭 이미지 관리")
  lazy var likeRoommateButton = createMatchingButton(imageName: "heart(MyPage)", title: "좋아요한 룸메")
  lazy var myPostButton = createCommunityButton(imageName: "write(MyPage)", title: "내가 쓴 글")
  lazy var myCommentButton = createCommunityButton(imageName: "like(MyPage)", title: "내가 쓴 댓글")
  lazy var myRecommendedPost = createCommunityButton(imageName: "message(MyPage)", title: "추천한 글")
  
  lazy var matchingLabel = createTitleLabel(title: "룸메이트 매칭 관리")
  lazy var communityLabel = createTitleLabel(title: "커뮤니티 관리")
  
  lazy var myProfileImage = UIImageView(image: UIImage(named: "myProfileImage(MyPage)"))
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.isHidden = true
  }
  
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .white
    navigationController?.navigationBar.isHidden = true
    topRoundedView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)
    
    [ matchingContainerView, communityContainerView, topRoundedView ]
      .forEach { view.addSubview($0) }
    
    matchingContainerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(topRoundedView.snp.bottom).offset(20)
    }
    
    communityContainerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(matchingContainerView.snp.bottom).offset(20)
    }
    
    topRoundedView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.height.equalTo(170)
    }
    
    [ myProfileImage, updateMyProfileImageButton ]
      .forEach { topRoundedView.addSubview($0) }
    
    updateMyProfileImageButton.snp.makeConstraints { make in
      make.bottom.equalToSuperview().inset(20)
      make.centerX.equalToSuperview()
    }
    
    myProfileImage.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(updateMyProfileImageButton.snp.top)
    }
    
    let matchingButtonStack = UIStackView(arrangedSubviews: [ matchingImageManagementButton, likeRoommateButton ])
    matchingButtonStack.spacing = 18
    matchingButtonStack.distribution = .fillEqually
    
    [ matchingLabel, matchingButtonStack ]
      .forEach { matchingContainerView.addSubview($0) }
    
    matchingLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(28)
      make.top.equalToSuperview().inset(16)
    }
    
    matchingButtonStack.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(28)
      make.top.equalTo(matchingLabel.snp.bottom).offset(16)
      make.bottom.equalToSuperview().inset(30)
    }
    
    let communityButtonStack = UIStackView(arrangedSubviews: [ myPostButton, myCommentButton, myRecommendedPost ])
    communityButtonStack.spacing = 12
    communityButtonStack.distribution = .fillEqually
    
    [ communityLabel, communityButtonStack ]
      .forEach { communityContainerView.addSubview($0) }
    
    communityLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(28)
      make.top.equalToSuperview().inset(16)
    }
    
    communityButtonStack.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(28)
      make.top.equalTo(communityLabel.snp.bottom).offset(16)
      make.bottom.equalToSuperview().inset(30)
    }
  }
  
  private func createMatchingButton(imageName: String, title: String) -> UIButton {
    var config = UIButton.Configuration.filled()
    config.image = UIImage(named: imageName)
    config.imagePlacement = .top
    config.imagePadding = 8
    var container = AttributeContainer()
    container.font = .init(name: Font.regular.rawValue, size: 12)
    container.foregroundColor = UIColor.black
    config.attributedTitle = AttributedString(title, attributes: container)
    config.titleAlignment = .center
    config.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 18, bottom: 18, trailing: 18)
    config.baseBackgroundColor = .idorm_gray_100
    let button = UIButton(configuration: config)
    button.layer.cornerRadius = 12
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .highlighted:
        button.configuration?.baseBackgroundColor = .idorm_gray_200
      default:
        button.configuration?.baseBackgroundColor = .idorm_gray_100
      }
    }
    button.configurationUpdateHandler = handler
    
    return button
  }
  
  private func createCommunityButton(imageName: String, title: String) -> UIButton {
    var config = UIButton.Configuration.filled()
    config.image = UIImage(named: imageName)
    config.imagePlacement = .top
    config.imagePadding = 8
    var container = AttributeContainer()
    container.font = .init(name: Font.regular.rawValue, size: 12)
    container.foregroundColor = UIColor.black
    config.attributedTitle = AttributedString(title, attributes: container)
    config.titleAlignment = .center
    config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 6, bottom: 12, trailing: 6)
    config.baseBackgroundColor = .idorm_gray_100
    let button = UIButton(configuration: config)
    button.layer.cornerRadius = 12
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .highlighted:
        button.configuration?.baseBackgroundColor = .idorm_gray_200
      default:
        button.configuration?.baseBackgroundColor = .idorm_gray_100
      }
    }
    button.configurationUpdateHandler = handler
    
    return button
  }
  
  private func createTitleLabel(title: String) -> UILabel {
    let label = UILabel()
    label.text = title
    label.font = .init(name: Font.medium.rawValue, size: 16)
    label.textColor = .black
    
    return label
  }
}
