//
//  MypageViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/17.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

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
    container.font = .init(name: MyFonts.medium.rawValue, size: 14)
    config.attributedTitle = AttributedString("내 정보 수정", attributes: container)
    config.baseForegroundColor = .white
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    let button = UIButton(configuration: config)
    
    return button
  }()
  
  lazy var scrollView: UIScrollView = {
    let sv = UIScrollView()
    sv.backgroundColor = .idorm_gray_100
    sv.bounces = false
    
    return sv
  }()
  
  lazy var contentsView: UIView = {
    let view = UIView()
    view.backgroundColor = .idorm_gray_100
    
    return view
  }()
  
  lazy var makePublicLabel: UILabel = {
    let label = UILabel()
    label.textColor = .idorm_gray_400
    label.font = .init(name: MyFonts.medium.rawValue, size: 14)
    label.text = "내 이미지 매칭페이지에 공유하기"
    
    return label
  }()
  
  lazy var makePublicButton: UIButton = {
    var config = UIButton.Configuration.plain()
    let btn = UIButton(configuration: config)
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .selected:
        button.configuration?.image = #imageLiteral(resourceName: "toggleHover(Matching)")
      default:
        button.configuration?.image = UIImage(named: "toggle(Matching)")
      }
    }
    btn.configurationUpdateHandler = handler

    return btn
  }()
  
  lazy var matchingImageManagementButton = MyPageUtilities.createMatchingButton(imageName: "picture(MyPage)", title: "매칭 이미지 관리")
  lazy var likeRoommateButton = MyPageUtilities.createMatchingButton(imageName: "heart(MyPage)", title: "좋아요한 룸메")
  lazy var myPostButton = MyPageUtilities.createCommunityButton(imageName: "write(MyPage)", title: "내가 쓴 글")
  lazy var myCommentButton = MyPageUtilities.createCommunityButton(imageName: "like(MyPage)", title: "내가 쓴 댓글")
  lazy var myRecommendedPostButton = MyPageUtilities.createCommunityButton(imageName: "message(MyPage)", title: "추천한 글")
  
  lazy var matchingLabel = MyPageUtilities.createTitleLabel(title: "룸메이트 매칭 관리")
  lazy var communityLabel = MyPageUtilities.createTitleLabel(title: "커뮤니티 관리")
  
  lazy var myProfileImage = UIImageView(image: UIImage(named: "myProfileImage(MyPage)"))
  lazy var gearImage = UIImageView(image: UIImage(named: "gear"))
  let lionImageView = UIImageView(image: #imageLiteral(resourceName: "BottonLion(MyPage)"))
  
  let disposeBag = DisposeBag()
  let viewModel = MyPageViewModel()
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureTopRoundedView()
    configureMatchingContainerView()
    configureCommunityContainerView()
    configureScrollView()
    configureTopView()
    bind()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.isHidden = true
    tabBarController?.tabBar.isHidden = false
    
    let appearance = UITabBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = .idorm_gray_100
    appearance.backgroundImage = UIImage()
    appearance.shadowImage = UIImage()
    appearance.shadowColor = .clear
    tabBarController?.tabBar.standardAppearance = appearance
    tabBarController?.tabBar.scrollEdgeAppearance = tabBarController?.tabBar.standardAppearance
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    let appearance = UITabBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = .white
    appearance.backgroundImage = UIImage()
    appearance.shadowImage = UIImage()
    appearance.shadowColor = .clear
    tabBarController?.tabBar.standardAppearance = appearance
    tabBarController?.tabBar.scrollEdgeAppearance = tabBarController?.tabBar.standardAppearance
  }
  
  // MARK: - Bind
  private func bind() {
    // ---------------------------------
    // ---------------INPUT-------------
    // ---------------------------------
    // 기어 이미지 터치 이벤트
    gearImage.rx.tapGesture()
      .map { _ in Void() }
      .bind(to: viewModel.input.gearImageTapped)
      .disposed(by: disposeBag)
    
    myPostButton.rx.tap
      .map { MyPostVCType.post }
      .bind(to: viewModel.input.myPostButtonTapped)
      .disposed(by: disposeBag)
    
    myCommentButton.rx.tap
      .map { MyPostVCType.comments }
      .bind(to: viewModel.input.myCommentsButtonTapped)
      .disposed(by: disposeBag)
    
    myRecommendedPostButton.rx.tap
      .map { MyPostVCType.recommend }
      .bind(to: viewModel.input.myRecommendButtonTapped)
      .disposed(by: disposeBag)
    
    likeRoommateButton.rx.tap
      .map { MyPostVCType.likeRoommate }
      .bind(to: viewModel.input.likeRoommateButtonTapped)
      .disposed(by: disposeBag)
    
    // ---------------------------------
    // --------------OUTPUT-------------
    // ---------------------------------
    viewModel.output.showMyPostVC
      .bind(onNext: { [weak self] type in
        let myPostVC = MyPostViewController(myPostVCType: type)
        self?.navigationController?.pushViewController(myPostVC, animated: true)
      })
      .disposed(by: disposeBag)
    
    viewModel.output.showOnboardingVC
      .bind(onNext: { [weak self] in
        let onboardingVC = OnboardingViewController(.update)
        self?.navigationController?.pushViewController(onboardingVC, animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Configuration
  private func configureTopView() {
    let topView = UIView()
    topView.backgroundColor = .idorm_blue
    view.addSubview(topView)
    
    topView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.bottom.equalTo(scrollView.snp.top)
    }
  }
  
  private func configureScrollView() {
    view.addSubview(scrollView)
    scrollView.addSubview(contentsView)
    
    scrollView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
    
    contentsView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalTo(view.frame.width)
    }
    
    [ matchingContainerView, communityContainerView, topRoundedView, lionImageView, gearImage ]
      .forEach { contentsView.addSubview($0) }
    
    topRoundedView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.height.equalTo(145)
    }
    
    gearImage.snp.makeConstraints { make in
      make.trailing.top.equalToSuperview().inset(16)
    }
    
    // 기기별 레이아웃
    let deviceManager = DeviceManager.shared
    if deviceManager.isXSeriesDevices_926() {
      matchingContainerView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(42)
        make.top.equalTo(topRoundedView.snp.bottom).offset(20)
      }
      
      communityContainerView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(42)
        make.top.equalTo(matchingContainerView.snp.bottom).offset(20)
      }
      
      lionImageView.snp.makeConstraints { make in
        make.top.equalTo(communityContainerView.snp.bottom).offset(114)
        make.bottom.equalToSuperview()
        make.centerX.equalToSuperview()
      }
    } else if deviceManager.isFourIncheDevices() {
      matchingContainerView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(12)
        make.top.equalTo(topRoundedView.snp.bottom).offset(20)
      }
      
      communityContainerView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(12)
        make.top.equalTo(matchingContainerView.snp.bottom).offset(20)
      }
      
      lionImageView.snp.makeConstraints { make in
        make.top.equalTo(communityContainerView.snp.bottom).offset(24)
        make.bottom.equalToSuperview()
        make.centerX.equalToSuperview()
      }
    } else if deviceManager.isFiveIncheDevices() {
      matchingContainerView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(topRoundedView.snp.bottom).offset(20)
      }
      
      communityContainerView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(matchingContainerView.snp.bottom).offset(20)
      }
      
      lionImageView.snp.makeConstraints { make in
        make.top.equalTo(communityContainerView.snp.bottom).offset(37)
        make.bottom.equalToSuperview()
        make.centerX.equalToSuperview()
      }
    } else if deviceManager.isFiveInchePlusDevices() {
      matchingContainerView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(32)
        make.top.equalTo(topRoundedView.snp.bottom).offset(20)
      }
      
      communityContainerView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(32)
        make.top.equalTo(matchingContainerView.snp.bottom).offset(20)
      }
      
      lionImageView.snp.makeConstraints { make in
        make.top.equalTo(communityContainerView.snp.bottom).offset(37)
        make.bottom.equalToSuperview()
        make.centerX.equalToSuperview()
      }
    } else if deviceManager.isXSeriesDevices_812() || deviceManager.isXSeriesDevices_844() {
      matchingContainerView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(topRoundedView.snp.bottom).offset(20)
      }
      
      communityContainerView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(matchingContainerView.snp.bottom).offset(20)
      }
      
      lionImageView.snp.makeConstraints { make in
        make.top.equalTo(communityContainerView.snp.bottom).offset(37)
        make.bottom.equalToSuperview()
        make.centerX.equalToSuperview()
      }
    } else if deviceManager.isXSeriesDevices_896() {
      matchingContainerView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(topRoundedView.snp.bottom).offset(20)
      }
      
      communityContainerView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(matchingContainerView.snp.bottom).offset(20)
      }
      
      lionImageView.snp.makeConstraints { make in
        make.top.equalTo(communityContainerView.snp.bottom).offset(87)
        make.bottom.equalToSuperview()
        make.centerX.equalToSuperview()
      }
    } else {
      matchingContainerView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(topRoundedView.snp.bottom).offset(20)
      }
      
      communityContainerView.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(matchingContainerView.snp.bottom).offset(20)
      }
      
      lionImageView.snp.makeConstraints { make in
        make.top.equalTo(communityContainerView.snp.bottom).offset(60)
        make.bottom.equalToSuperview()
        make.centerX.equalToSuperview()
      }
    }
  }
  
  private func configureTopRoundedView() {
    topRoundedView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)

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
  }
  
  private func configureMatchingContainerView() {
    let matchingButtonStack = UIStackView(arrangedSubviews: [ matchingImageManagementButton, likeRoommateButton ])
    matchingButtonStack.spacing = 18
    matchingButtonStack.distribution = .fillEqually
    
    [ matchingLabel, matchingButtonStack, makePublicLabel, makePublicButton ]
      .forEach { matchingContainerView.addSubview($0) }
    
    matchingLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(28)
      make.top.equalToSuperview().inset(16)
    }
    
    matchingButtonStack.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(28)
      make.top.equalTo(matchingLabel.snp.bottom).offset(16)
    }
    
    makePublicLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(28)
      make.top.equalTo(matchingButtonStack.snp.bottom).offset(16)
      make.bottom.equalToSuperview().inset(24)
    }
    
    makePublicButton.snp.makeConstraints { make in
      make.centerY.equalTo(makePublicLabel)
      make.leading.equalTo(makePublicLabel.snp.trailing)
    }
  }
  
  private func configureCommunityContainerView() {
    let communityButtonStack = UIStackView(arrangedSubviews: [ myPostButton, myCommentButton, myRecommendedPostButton ])
    communityButtonStack.spacing = 5
    communityButtonStack.distribution = .fillEqually
    
    [ communityLabel, communityButtonStack ]
      .forEach { communityContainerView.addSubview($0) }
    
    communityLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(28)
      make.top.equalToSuperview().inset(16)
    }
    
    communityButtonStack.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(21)
      make.top.equalTo(communityLabel.snp.bottom).offset(16)
      make.bottom.equalToSuperview().inset(21)
    }
  }
}
