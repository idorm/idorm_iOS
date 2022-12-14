import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa

final class CompleteSignUpViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let signUpLabel = UILabel().then {
    $0.textColor = .idorm_gray_400
    $0.text = "안녕하세요! 가입을 축하드려요."
    $0.textAlignment = .center
    $0.font = .init(name: MyFonts.bold.rawValue, size: 18.0)
  }
  
  private let descriptionLabel1 = UILabel().then {
    $0.font = .init(name: MyFonts.medium.rawValue, size: 12.0)
    $0.textColor = .idorm_gray_300
    $0.textAlignment = .center
    $0.text = "로그인 후 인천대학교 기숙사 룸메이트 매칭을 위한"
  }
  
  private let descriptionLabel2 = UILabel().then {
    $0.font = .init(name: MyFonts.medium.rawValue, size: 12.0)
    $0.textColor = .idorm_gray_300
    $0.textAlignment = .center
    $0.text = "기본정보를 알려주세요."
  }
  
  private let continueButton = UIButton().then {
    var config = UIButton.Configuration.filled()
    var container = AttributeContainer()
    container.font = UIFont.init(name: MyFonts.medium.rawValue, size: 16)
    container.foregroundColor = UIColor.white
    config.attributedTitle = AttributedString("로그인 후 계속하기", attributes: container)
    config.baseBackgroundColor = .idorm_blue
    config.cornerStyle = .capsule
    config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 40, bottom: 10, trailing: 40)
    
    $0.configuration = config
  }
  
  private let indicator = UIActivityIndicatorView().then {
    $0.color = .gray
  }
  
  private let image = UIImageView(image: #imageLiteral(resourceName: "Lion"))
  
  private let viewModel = CompleteSignUpViewModel()
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // MARK: - Input
    
    // 로그인 후 계속하기 버튼 이벤트
    continueButton.rx.tap
      .bind(to: viewModel.input.continueButtonDidTap)
      .disposed(by: disposeBag)
    
    // MARK: - Output
    
    // 온보딩 페이지로 이동
    viewModel.output.presentOnboardingVC
      .bind(onNext: { [weak self] in
        let onboardingVC = UINavigationController(rootViewController: OnboardingViewController(.initial))
        onboardingVC.modalPresentationStyle = .fullScreen
        self?.present(onboardingVC, animated: true)
      })
      .disposed(by: disposeBag)
    
    // 팝업 창 띄우기
    viewModel.output.presentPopupVC
      .withUnretained(self)
      .bind { owner, content in
        let viewController = BasicPopup(contents: content)
        viewController.modalPresentationStyle = .overFullScreen
        owner.present(viewController, animated: false)
      }
      .disposed(by: disposeBag)
    
    // 로딩 인디케이터
    viewModel.output.isLoading
      .bind(to: indicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    // 화면 터치 제어
    viewModel.output.isLoading
      .map { !$0 }
      .bind(to: view.rx.isUserInteractionEnabled)
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [image, signUpLabel, descriptionLabel1, descriptionLabel2, continueButton, indicator]
      .forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    image.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(-100)
    }
    
    signUpLabel.snp.makeConstraints { make in
      make.top.equalTo(image.snp.bottom).offset(70)
      make.centerX.equalToSuperview()
    }
    
    descriptionLabel1.snp.makeConstraints { make in
      make.top.equalTo(signUpLabel.snp.bottom).offset(12)
      make.centerX.equalToSuperview()
    }
    
    descriptionLabel2.snp.makeConstraints { make in
      make.top.equalTo(descriptionLabel1.snp.bottom).offset(4)
      make.centerX.equalToSuperview()
    }
    
    continueButton.snp.makeConstraints { make in
      make.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
      make.centerX.equalToSuperview()
    }
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(20)
    }
  }
}
