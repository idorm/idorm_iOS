import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa
import RxGesture
import RxAppState
import RxOptional

final class MyPageViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let indicator = UIActivityIndicatorView().then {
    $0.color = .gray
  }
  
  private let scrollView = UIScrollView().then {
    $0.bounces = false
  }
  
  private let contentView = UIView().then {
    $0.backgroundColor = .idorm_gray_100
  }
  
  private let gearButton = UIButton().then {
    $0.setImage(#imageLiteral(resourceName: "gear"), for: .normal)
  }
  
  private let lionImageView = UIImageView(image: #imageLiteral(resourceName: "BottonLion(MyPage)"))
  private let topProfileView = TopProfileView()
  private let matchingContainerView = MatchingContainerView()
  
  private let viewModel = MyPageViewModel()
  
  // MARK: - LifeCycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.isHidden = false
    tabBarController?.tabBar.isHidden = false
    
    let navigationBarAppearance = AppearanceManager.navigationAppearance(from: .idorm_blue, shadow: false)
    navigationController?.navigationBar.standardAppearance = navigationBarAppearance
    navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    navigationController?.navigationBar.compactAppearance = navigationBarAppearance
    
    let tabBarAppearance = AppearanceManager.tabbarAppearance(from: .idorm_gray_100)
    tabBarController?.tabBar.standardAppearance = tabBarAppearance
    tabBarController?.tabBar.scrollEdgeAppearance = tabBarAppearance
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    let navigationBarAppearance = AppearanceManager.navigationAppearance(from: .white, shadow: false)
    navigationController?.navigationBar.standardAppearance = navigationBarAppearance
    navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    navigationController?.navigationBar.compactAppearance = navigationBarAppearance
    
    let tabBarAppearance = AppearanceManager.tabbarAppearance(from: .white)
    tabBarController?.tabBar.standardAppearance = tabBarAppearance
    tabBarController?.tabBar.scrollEdgeAppearance = tabBarAppearance
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // MARK: - Input
    
    // 설정 버튼 클릭 이벤트
    gearButton.rx.tap
      .bind(to: viewModel.input.gearButtonDidTap)
      .disposed(by: disposeBag)
    
    // 마이페이지 버튼 클릭 이벤트
    matchingContainerView.manageMatchingImageButton.rx.tap
      .bind(to: viewModel.input.manageButtonDidTap)
      .disposed(by: disposeBag)
    
    // 공유 버튼 터치
    matchingContainerView.shareButton.rx.tap
      .withUnretained(self)
      .map { $0.0 }
      .map { !$0.matchingContainerView.shareButton.isSelected }
      .bind(to: viewModel.input.shareButtonDidTap)
      .disposed(by: disposeBag)
    
    // 좋아요한 멤버 버튼 클릭 이벤트
    matchingContainerView.likedRoommateButton.rx.tap
      .map { MyPageVCTypes.MyRoommateVCType.like }
      .bind(to: viewModel.input.roommateButtonDidTap)
      .disposed(by: disposeBag)
    
    // 싫어요한 멤버 버튼 클릭 이벤트
    matchingContainerView.dislikedRoommateButton.rx.tap
      .map { MyPageVCTypes.MyRoommateVCType.dislike }
      .bind(to: viewModel.input.roommateButtonDidTap)
      .disposed(by: disposeBag)
    
    // 화면 최초 접속 이벤트
    rx.viewWillAppear
      .map { _ in Void() }
      .bind(to: viewModel.input.viewWillAppear)
      .disposed(by: disposeBag)
    
    // MARK: - Output
    
    // 내 정보 관리 페이지로 이동
    viewModel.output.pushToManageMyInfoVC
      .withUnretained(self)
      .map { $0.0 }
      .bind {
        let manageMyInfoVC = ManageMyInfoViewController()
        manageMyInfoVC.hidesBottomBarWhenPushed = true
        $0.navigationController?.pushViewController(manageMyInfoVC, animated: true)
      }
      .disposed(by: disposeBag)
    
    // 룸메이트 관리 페이지로 이동
    viewModel.output.pushToMyRoommateVC
      .withUnretained(self)
      .bind(onNext: { owner, type in
        let viewController = MyRoommateViewController(type)
        viewController.hidesBottomBarWhenPushed = true
        owner.navigationController?.pushViewController(viewController, animated: true)
      })
      .disposed(by: disposeBag)
    
    // 온보딩 수정 페이지로 이동
    viewModel.output.pushToOnboardingVC
      .withUnretained(self)
      .bind(onNext: { owner, state in
        if state {
          let matchingMember = MemberInfoStorage.instance.onboardingToMatchingMember()
          let viewController = OnboardingDetailViewController(matchingMember, vcType: .update)
          viewController.hidesBottomBarWhenPushed = true
          owner.navigationController?.pushViewController(viewController, animated: true)
        } else {
          let viewController = OnboardingViewController(.initial2)
          viewController.hidesBottomBarWhenPushed = true
          owner.navigationController?.pushViewController(viewController, animated: true)
        }
      })
      .disposed(by: disposeBag)
    
    // 공유 버튼 토클
    viewModel.output.toggleShareButton
      .bind(to: matchingContainerView.shareButton.rx.isSelected)
      .disposed(by: disposeBag)
    
    // 인디케이터 애니메이션 제어
    viewModel.output.isLoading
      .bind(to: indicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    // 화면 인터렉션 제어
    viewModel.output.isLoading
      .map { !$0 }
      .bind(to: view.rx.isUserInteractionEnabled)
      .disposed(by: disposeBag)
    
    // 공유 버튼 업데이트
    viewModel.output.updateShareButton
      .bind(to: matchingContainerView.shareButton.rx.isSelected)
      .disposed(by: disposeBag)
    
    // 닉네임 업데이트
    viewModel.output.updateNickname
      .bind(to: topProfileView.nicknameLabel.rx.text)
      .disposed(by: disposeBag)
    
    // 프로필 이미지 만들기 팝업
    viewModel.output.presentNoMatchingInfoPopupVC
      .withUnretained(self)
      .map { $0.0 }
      .bind {
        let viewController = NoMatchingInfoPopupViewController()
        viewController.modalPresentationStyle = .overFullScreen
        $0.present(viewController, animated: false)
        
        // 프로필 이미지 만들기 버튼 클릭
        viewController.makeButton.rx.tap
          .bind(to: $0.viewModel.input.makeProfileImageButtonDidTap)
          .disposed(by: $0.disposeBag)
        
        // 팝업창 닫기
        $0.viewModel.output.dismissPopupVC
          .bind { viewController.dismiss(animated: false) }
          .disposed(by: $0.disposeBag)
      }
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .white
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: gearButton)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    view.addSubview(scrollView)
    view.addSubview(indicator)
    scrollView.addSubview(contentView)
    
    [topProfileView, matchingContainerView, lionImageView]
      .forEach { contentView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    scrollView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalTo(scrollView.snp.width)
      make.height.equalTo(scrollView.snp.height)
    }
    
    topProfileView.snp.makeConstraints { make in
      make.leading.trailing.top.equalToSuperview()
      make.height.equalTo(146)
    }
    
    matchingContainerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(topProfileView.snp.bottom).offset(24)
    }
    
    lionImageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }
}
