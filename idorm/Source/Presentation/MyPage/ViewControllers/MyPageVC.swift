//
//  MyPageViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/21.
//

import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa
import RxGesture
import RxAppState
import RxOptional
import ReactorKit

final class MyPageViewController: BaseViewController, View {
  
  // MARK: - Properties
  
  private lazy var indicator = UIActivityIndicatorView().then {
    $0.color = .gray
  }
  
  private let scrollView = UIScrollView().then {
    $0.contentInsetAdjustmentBehavior = .never
    $0.bounces = false
  }
  
  private let contentView = UIView().then {
    $0.backgroundColor = .idorm_gray_100
  }
  
  private let lionImageView = UIImageView(image: #imageLiteral(resourceName: "lion_half"))
  private let topProfileView = TopProfileView()
  private let matchingContainerView = MatchingContainerView()
  private let communityContainerView = CommunityContainerView()
  override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
  
  // MARK: - LifeCycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
    tabBarController?.tabBar.isHidden = false
    
    let tabBarAppearance = NavigationAppearanceUtils.tabbarAppearance(from: .idorm_gray_100)
    tabBarController?.tabBar.standardAppearance = tabBarAppearance
    tabBarController?.tabBar.scrollEdgeAppearance = tabBarAppearance
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    let tabBarAppearance = NavigationAppearanceUtils.tabbarAppearance(from: .white)
    tabBarController?.tabBar.standardAppearance = tabBarAppearance
    tabBarController?.tabBar.scrollEdgeAppearance = tabBarAppearance
  }
  
  // MARK: - Bind
  
  func bind(reactor: MyPageViewReactor) {
    
    // MARK: - Action
    
    // viewWillAppear
    rx.viewWillAppear
      .map { _ in MyPageViewReactor.Action.viewWillAppear }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
        
    // 설정 버튼 클릭
    topProfileView.gearBtn.rx.tap
      .map { MyPageViewReactor.Action.didTapGearButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 매칭이미지 버튼 클릭
    matchingContainerView.matchingImageButton.rx.tap
      .map { MyPageViewReactor.Action.didTapMatchingImageButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 좋아요한 룸메이트 버튼 클릭
    matchingContainerView.likeButton.rx.tap
      .map { MyPageViewReactor.Action.didTapRoommateButton(.like) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 싫어요한 룸메이트 버튼 클릭
    matchingContainerView.dislikeButton.rx.tap
      .map { MyPageViewReactor.Action.didTapRoommateButton(.dislike) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 공유 버튼 클릭
    matchingContainerView.shareButton.rx.tap
      .withUnretained(self)
      .map { !$0.0.matchingContainerView.shareButton.isSelected }
      .map { MyPageViewReactor.Action.didTapShareButton($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // MARK: - State
    
    // 마이페이지 관리 페이지 이동
    reactor.state
      .map { $0.isOpenedManageMyInfoVC }
      .distinctUntilChanged()
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let viewController = ManageMyInfoViewController()
        viewController.reactor = ManageMyInfoViewReactor()
        viewController.hidesBottomBarWhenPushed = true
        owner.navigationController?.pushViewController(viewController, animated: true)
      }
      .disposed(by: disposeBag)
    
    // 온보딩 페이지 이동
    reactor.state
      .map { $0.isOpenedOnboardingVC }
      .distinctUntilChanged()
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let viewController = OnboardingViewController(.main)
        viewController.reactor = OnboardingViewReactor(.main)
        viewController.hidesBottomBarWhenPushed = true
        owner.navigationController?.pushViewController(viewController, animated: true)
      }
      .disposed(by: disposeBag)
    
    // 온보딩 디테일 페이지 이동
    reactor.state
      .map { $0.isOpenedOnboardingDetailVC }
      .filter { $0.0 }
      .withUnretained(self)
      .bind { owner, member in
        let onboardingDetailVC = OnboardingDetailViewController(member.1, type: .modify)
        onboardingDetailVC.reactor = OnboardingDetailViewReactor(.modify)
        onboardingDetailVC.hidesBottomBarWhenPushed = true
        owner.navigationController?.pushViewController(onboardingDetailVC, animated: true)
      }
      .disposed(by: disposeBag)
    
    // 매칭정보없음 팝업
    reactor.state
      .map { $0.isOpenedNoMatchingInfoPopup }
      .distinctUntilChanged()
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let popup = NoMatchingInfoPopup()
        popup.modalPresentationStyle = .overFullScreen
        owner.present(popup, animated: false)
        
        // 프로필 이미지 만들기 버튼
        popup.makeButton.rx.tap
          .map { MyPageViewReactor.Action.didTapMakeProfileButton }
          .bind(to: reactor.action)
          .disposed(by: owner.disposeBag)
        
        // 팝업 창 닫기
        reactor.state
          .map { $0.isDismissedPopup }
          .filter { $0 }
          .bind { _ in popup.dismiss(animated: false) }
          .disposed(by: owner.disposeBag)
      }
      .disposed(by: disposeBag)
    
    // 좋아요 룸메이트 관리 페이지 이동
    reactor.state
      .map { $0.isOpenedLikedRoommateVC }
      .distinctUntilChanged()
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let viewController = MyRoommateViewController(.like)
        viewController.reactor = MyRoommateViewReactor()
        viewController.hidesBottomBarWhenPushed = true
        owner.navigationController?.pushViewController(viewController, animated: true)
      }
      .disposed(by: disposeBag)
    
    // 싫어요 룸메이트 관리 페이지 이동
    reactor.state
      .map { $0.isOpenedDislikedRoommateVC }
      .distinctUntilChanged()
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let viewController = MyRoommateViewController(.dislike)
        viewController.reactor = MyRoommateViewReactor()
        viewController.hidesBottomBarWhenPushed = true
        owner.navigationController?.pushViewController(viewController, animated: true)
      }
      .disposed(by: disposeBag)
    
    // 공유버튼 토글
    reactor.state
      .map { $0.isSelectedShareButton }
      .distinctUntilChanged()
      .bind(to: matchingContainerView.shareButton.rx.isSelected)
      .disposed(by: disposeBag)
    
    // 현재 닉네임 변경
    reactor.state
      .map { $0.currentNickname }
      .distinctUntilChanged()
      .bind(to: topProfileView.nicknameLabel.rx.text)
      .disposed(by: disposeBag)
    
    // 로딩 중
    reactor.state
      .map { $0.isLoading }
      .distinctUntilChanged()
      .withUnretained(self)
      .bind { owner, isLoading in
        if isLoading {
          owner.indicator.startAnimating()
          owner.view.isUserInteractionEnabled = false
        } else {
          owner.indicator.stopAnimating()
          owner.view.isUserInteractionEnabled = true
        }
      }
      .disposed(by: disposeBag)
  }

  // MARK: - Setup
  
  override func setupStyles() {
    view.backgroundColor = .idorm_blue
  }
  
  override func setupLayouts() {
    view.addSubview(scrollView)
    view.addSubview(indicator)
    scrollView.addSubview(contentView)
    
    [
      topProfileView,
      matchingContainerView,
      communityContainerView,
      lionImageView
    ].forEach { contentView.addSubview($0) }
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
    }
    
    topProfileView.snp.makeConstraints { make in
      make.leading.trailing.top.equalToSuperview()
      make.height.equalTo(190)
    }
    
    matchingContainerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(topProfileView.snp.bottom).offset(24)
    }
    
    communityContainerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(matchingContainerView.snp.bottom).offset(24)
    }
    
    lionImageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(communityContainerView.snp.bottom).offset(24)
      make.bottom.equalToSuperview()
    }
  }
}
