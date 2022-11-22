import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa
import RxGesture

final class MyPageViewController: BaseViewController {
  
  // MARK: - Properties
  
  private var scrollView: UIScrollView!
  private var contentView: UIView!
  private var gearButton: UIButton!
    
  private let lionImageView = UIImageView(image: #imageLiteral(resourceName: "BottonLion(MyPage)"))
  private let topProfileView = TopProfileView()
  private let matchingContainerView = MatchingContainerView()
  
  private let viewModel = MyPageViewModel()
  private let indicator = UIActivityIndicatorView()
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    setupScrollView()
    super.viewDidLoad()
  }
  
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
    
    // 화면 접근시 이벤트 방출
    viewModel.input.viewWillAppearObserver.onNext(Void())
    
    updateUI()
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

    // 공유 버튼 토글
    matchingContainerView.shareButton.rx.tap
      .map { [unowned self] in return !self.matchingContainerView.shareButton.isSelected }
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
        
    // MARK: - Output
    
    // 내 정보 관리 페이지로 이동
    viewModel.output.pushToManageMyInfoVC
      .bind(onNext: { [unowned self] in
        let manageMyInfoVC = ManageMyInfoViewController()
        manageMyInfoVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(manageMyInfoVC, animated: true)
      })
      .disposed(by: disposeBag)
    
    // 내 멤버 조회 완료 후 UI 업데이트
    MemberInfoStorage.instance.myInformation
      .bind(onNext: { [unowned self] information in
        let nickname = information?.nickname
        self.topProfileView.nicknameLabel.text = nickname
      })
      .disposed(by: disposeBag)
    
    // 룸메이트 관리 페이지로 이동
    viewModel.output.pushToMyRoommateVC
      .bind(onNext: { [weak self] in
        let viewController = MyRoommateViewController($0)
        viewController.hidesBottomBarWhenPushed = true
        self?.navigationController?.pushViewController(viewController, animated: true)
      })
      .disposed(by: disposeBag)
    
    // 온보딩 수정 페이지로 이동
    viewModel.output.pushToOnboardingVC
      .bind(onNext: { [weak self] in
        if MemberInfoStorage.instance.hasMatchingInfo {
          let matchingMember = MemberInfoStorage.instance.onboardingToMatchingMember()
          let viewController = OnboardingDetailViewController(matchingMember, vcType: .update)
          viewController.hidesBottomBarWhenPushed = true
          self?.navigationController?.pushViewController(viewController, animated: true)
        } else {
          let viewController = OnboardingViewController(.mainPage_FirstTime)
          viewController.hidesBottomBarWhenPushed = true
          self?.navigationController?.pushViewController(viewController, animated: true)
        }
      })
      .disposed(by: disposeBag)
    
    // 공유 버튼 토클
    viewModel.output.toggleShareButton
      .bind(onNext: { [weak self] in
        self?.matchingContainerView.shareButton.isSelected.toggle()
      })
      .disposed(by: disposeBag)

    // 화면 인터렉션 제어
    viewModel.output.indicatorState
      .bind(onNext: { [weak self] in
        if $0 {
          self?.view.isUserInteractionEnabled = false
        } else {
          self?.view.isUserInteractionEnabled = true
        }
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  private func setupScrollView() {
    let scrollView = UIScrollView()
    scrollView.bounces = false
    self.scrollView = scrollView
    
    let contentView = UIView()
    contentView.backgroundColor = .idorm_gray_100
    self.contentView = contentView
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    view.backgroundColor = .white
    let gearButton = UIButton()
    gearButton.setImage(UIImage(named: "gear"), for: .normal)
    self.gearButton = gearButton
    
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
  
  // MARK: - Helpers
  
  private func updateUI() {
    if MemberInfoStorage.instance.isPublicMatchingInfo {
      matchingContainerView.shareButton.isSelected = true
    } else {
      matchingContainerView.shareButton.isSelected = false
    }
    guard let myInformation = MemberInfoStorage.instance.myInformation.value else { return }
    topProfileView.nicknameLabel.text = myInformation.nickname
  }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct MyPageVC_PreView: PreviewProvider {
  static var previews: some View {
    MyPageViewController().toPreview()
  }
}
#endif
