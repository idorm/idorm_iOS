import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa

final class OnboardingDetailViewController: BaseViewController {

  // MARK: - Properties

  private let backButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
    button.tintColor = .black

    return button
  }()

  private var floatyBottomView: FloatyBottomView!
  private var matchingCard: MatchingCard!
  private let indicator = UIActivityIndicatorView()

  private let viewModel: OnboardingDetailViewModel
  
  private let member: MatchingModel.Member
  private let vcType: OnboardingVCTypes.OnboardingDetailVCType
  
  // MARK: - Init
  
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
    
    switch vcType {
    case .initilize:
      // 뒤로 가기 버튼 이벤트
      floatyBottomView.skipButton.rx.tap
        .bind(to: viewModel.input.backButtonDidTap)
        .disposed(by: disposeBag)
      
    case .update:
      // 정보 수정 버튼 이벤트
      floatyBottomView.skipButton.rx.tap
        .bind(to: viewModel.input.correctionButtonDidTap)
        .disposed(by: disposeBag)
    }

    // 완료 버튼 이벤트
    floatyBottomView.confirmButton.rx.tap
      .map { [unowned self] in return self.member }
      .bind(to: viewModel.input.confirmButtonDidTap)
      .disposed(by: disposeBag)

    // MARK: - Output

    // 뒤로가기
    viewModel.output.popVC
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        self?.navigationController?.popViewController(animated: true)
      })
      .disposed(by: disposeBag)
    
    // 온보딩 페이지로 넘어가기
    viewModel.output.showOnboardingVC
      .bind(onNext: { [weak self] in
        let viewController = OnboardingViewController(.update)
        self?.navigationController?.pushViewController(viewController, animated: true)
      })
      .disposed(by: disposeBag)
    
    // 인디케이터 제어
    viewModel.output.indicatorState
      .bind(onNext: { [weak self] in
        if $0 {
          self?.indicator.startAnimating()
          self?.view.isUserInteractionEnabled = false
        } else {
          self?.indicator.stopAnimating()
          self?.view.isUserInteractionEnabled = true
        }
      })
      .disposed(by: disposeBag)
    
    // 최초 저장 완료 후 메인 홈으로 이동
    viewModel.output.showTabBarVC
      .bind(onNext: { [weak self] in
        let tabBarVC = TabBarController()
        tabBarVC.modalPresentationStyle = .fullScreen
        self?.present(tabBarVC, animated: true)
      })
      .disposed(by: disposeBag)

    // 오류 팝업 메세지 띄우기
    viewModel.output.showPopupVC
      .bind(onNext: { [weak self] mention in
        let popupVC = PopupViewController(contents: mention)
        popupVC.modalPresentationStyle = .overFullScreen
        self?.present(popupVC, animated: false)
      })
      .disposed(by: disposeBag)
  }
}
