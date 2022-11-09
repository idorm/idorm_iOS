import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa

class CompleteSignUpViewController: BaseViewController {
  
  // MARK: - Properties
  
  private lazy var signUpLabel = UILabel().then {
    $0.textColor = .idorm_gray_400
    $0.text = "안녕하세요! 가입을 축하드려요."
    $0.textAlignment = .center
    $0.font = .init(name: MyFonts.bold.rawValue, size: 18.0)
  }
  
  private lazy var descriptionLabel1 = UILabel().then {
    $0.font = .init(name: MyFonts.medium.rawValue, size: 12.0)
    $0.textColor = .idorm_gray_300
    $0.textAlignment = .center
    $0.text = "로그인 후 인천대학교 기숙사 룸메이트 매칭을 위한"
  }
  
  private lazy var descriptionLabel2 = UILabel().then {
    $0.font = .init(name: MyFonts.medium.rawValue, size: 12.0)
    $0.textColor = .idorm_gray_300
    $0.textAlignment = .center
    $0.text = "기본정보를 알려주세요."
  }
  
  private lazy var continueButton = UIButton().then {
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
  
  private let indicator = UIActivityIndicatorView()
  private let image = UIImageView(image: UIImage(named: "Lion"))
  
  private let viewModel = CompleteSignUpViewModel()
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // --------------------------------
    // --------------INPUT-------------
    // --------------------------------
    
    /// 로그인 후 계속하기 버튼 이벤트
    continueButton.rx.tap
      .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
      .bind(to: viewModel.input.continueButtonTapped)
      .disposed(by: disposeBag)
    
    // --------------------------------
    // --------------OUTPUT------------
    // --------------------------------
    
    /// 온보딩 페이지로 이동
    viewModel.output.showOnboardingVC
      .bind(onNext: { [unowned self] in
        let onboardingVC = UINavigationController(rootViewController: OnboardingViewController(.firstTime))
        onboardingVC.modalPresentationStyle = .fullScreen
        self.present(onboardingVC, animated: true)
      })
      .disposed(by: disposeBag)
    
    /// 애니메이션 시작
    viewModel.output.startAnimation
      .bind(onNext: { [weak self] in
        self?.indicator.startAnimating()
        self?.view.isUserInteractionEnabled = false
      })
      .disposed(by: disposeBag)
    
    /// 애니메이션 종료
    viewModel.output.stopAnimation
      .bind(onNext: { [weak self] in
        self?.indicator.stopAnimating()
        self?.view.isUserInteractionEnabled = true
      })
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
