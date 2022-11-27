import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa

final class OnboardingDetailViewController: BaseViewController {

  // MARK: - Properties

  private var floatyBottomView: FloatyBottomView!
  private var matchingCard: MatchingCard!
  
  private let indicator = UIActivityIndicatorView().then {
    $0.color = .gray
  }

  private let viewModel: OnboardingDetailViewModel
  
  private let member: MatchingModel.Member
  private let vcType: OnboardingVCTypes.OnboardingDetailVCType
  
  // MARK: - LifeCycle
  
  init(_ member: MatchingModel.Member, vcType: OnboardingVCTypes.OnboardingDetailVCType) {
    self.viewModel = OnboardingDetailViewModel(vcType)
    self.member = member
    self.vcType = vcType
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    setupMatchingCard()
    setupFloatyBottomView()
    super.viewDidLoad()
  }

  // MARK: - Setup
  
  private func setupMatchingCard() {
    let matchingCard = MatchingCard(member)
    self.matchingCard = matchingCard
  }
  
  private func setupFloatyBottomView() {
    switch vcType {
    case .update:
      self.floatyBottomView = FloatyBottomView(.correction)
    case .initilize:
      self.floatyBottomView = FloatyBottomView(.back)
    }
  }

  override func setupLayouts() {
    super.setupLayouts()
    [floatyBottomView, matchingCard, indicator]
      .forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()

    floatyBottomView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
      make.height.equalTo(76)
    }

    matchingCard.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.centerY.equalTo(view.safeAreaLayoutGuide).offset(-50)
      make.height.equalTo(431)
    }

    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(20)
    }
  }

  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .white
    navigationItem.title = "내 프로필 이미지"
  }
  
  // MARK: - Bind

  override func bind() {
    super.bind()

    // MARK: - Input
    
    // 왼쪽 버튼 클릭
    floatyBottomView.leftButton.rx.tap
      .bind(to: viewModel.input.leftButtonDidTap)
      .disposed(by: disposeBag)
    
    // 오른쪽 버튼 클릭
    floatyBottomView.rightButton.rx.tap
      .withUnretained(self)
      .map { $0.0 }
      .map { $0.member }
      .bind(to: viewModel.input.rightButtonDidTap)
      .disposed(by: disposeBag)

    // MARK: - Output

    // 뒤로가기
    viewModel.output.popVC
      .withUnretained(self)
      .map { $0.0 }
      .bind(onNext: { $0.navigationController?.popViewController(animated: true) })
      .disposed(by: disposeBag)
    
    // 온보딩 페이지로 넘어가기
    viewModel.output.pushToOnboardingVC
      .withUnretained(self)
      .map { $0.0 }
      .bind(onNext: {
        let viewController = OnboardingViewController(.update)
        $0.navigationController?.pushViewController(viewController, animated: true)
      })
      .disposed(by: disposeBag)
    
    // 인디케이터 제어
    viewModel.output.isLoading
      .bind(to: indicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    // 화면 인터렉션 제어
    viewModel.output.isLoading
      .map { !$0 }
      .bind(to: view.rx.isUserInteractionEnabled)
      .disposed(by: disposeBag)
    
    // 최초 저장 완료 후 메인 홈으로 이동
    viewModel.output.presentMainVC
      .withUnretained(self)
      .map { $0.0 }
      .bind(onNext: {
        let tabBarVC = TabBarController()
        tabBarVC.modalPresentationStyle = .fullScreen
        $0.present(tabBarVC, animated: true)
      })
      .disposed(by: disposeBag)

    // 오류 팝업 메세지 띄우기
    viewModel.output.presentPopupVC
      .withUnretained(self)
      .bind(onNext: { owner, mention in
        let popupVC = PopupViewController(contents: mention)
        popupVC.modalPresentationStyle = .overFullScreen
        owner.present(popupVC, animated: false)
      })
      .disposed(by: disposeBag)
  }
}
