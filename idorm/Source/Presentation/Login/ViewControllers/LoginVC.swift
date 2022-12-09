import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa

final class LoginViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let loginTitleLabel = UILabel().then {
    $0.font = .init(name: MyFonts.bold.rawValue, size: 24)
    $0.text = "로그인"
    $0.textColor = .black
  }
  
  private let loginLabel = UILabel().then {
    $0.text = "인천대학교 이메일로 로그인해주세요."
    $0.textColor = .darkGray
    $0.font = .init(name: MyFonts.medium.rawValue, size: 12)
  }
  
  private let idTextField = LoginTextField("이메일").then {
    $0.textContentType = .emailAddress
  }
  
  private let pwTextField = LoginTextField("비밀번호").then {
    $0.keyboardType = .alphabet
    $0.isSecureTextEntry = true
  }
  
  private let loginButton = UIButton().then {
    var config = UIButton.Configuration.filled()
    var container = AttributeContainer()
    container.font = .init(name: MyFonts.medium.rawValue, size: 14)
    container.foregroundColor = UIColor.white
    config.attributedTitle = AttributedString("로그인", attributes: container)
    config.baseBackgroundColor = .idorm_blue
    config.background.cornerRadius = 10
    
    $0.configuration = config
  }
  
  private let forgotPwButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    var container = AttributeContainer()
    container.foregroundColor = UIColor.idorm_gray_300
    container.font = .init(name: MyFonts.medium.rawValue, size: 12)
    config.attributedTitle = AttributedString("비밀번호를 잊으셨나요?", attributes: container)
    
    $0.configuration = config
  }
  
  private let signUpLabel = UILabel().then {
    $0.text = "아직 계정이 없으신가요?"
    $0.textColor = .idorm_gray_300
    $0.font = .init(name: MyFonts.medium.rawValue, size: FontSize.largeDescription.rawValue)
  }
  
  private let signUpButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    var container = AttributeContainer()
    container.foregroundColor = UIColor.idorm_blue
    container.font = .init(name: MyFonts.medium.rawValue, size: 12)
    config.attributedTitle = AttributedString("회원가입", attributes: container)
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    
    $0.configuration = config
  }
  
  private let indicator = UIActivityIndicatorView().then {
    $0.color = .darkGray
  }
  
  private let idormMarkImage = UIImageView(image: UIImage(named: "i dorm Mark"))
  private let inuMarkImage = UIImageView(image: UIImage(named: "INUMark"))
  private var loginStack: UIStackView!
  private var loginTextFieldStack: UIStackView!
  private var signUpStack: UIStackView!
  
  private let viewModel = LoginViewModel()
  
  //MARK: - LifeCycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.isNavigationBarHidden = true
    
    // 토큰 초기화
    TokenStorage.instance.removeToken()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.isNavigationBarHidden = false
  }
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [idormMarkImage, loginTitleLabel, loginTextFieldStack, loginStack, loginButton, forgotPwButton, signUpStack, indicator]
      .forEach { view.addSubview($0) }
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    view.backgroundColor = .white
    navigationController?.isNavigationBarHidden = true
    navigationController?.navigationBar.tintColor = .black
    navigationItem.title = "로그인"
    
    let loginStack = UIStackView(arrangedSubviews: [ inuMarkImage, loginLabel ])
    loginStack.axis = .horizontal
    loginStack.spacing = 8.0
    
    let loginTextFieldStack = UIStackView(arrangedSubviews: [ idTextField, pwTextField ])
    loginTextFieldStack.axis = .vertical
    loginTextFieldStack.distribution = .fillEqually
    loginTextFieldStack.spacing = 10.0
    
    let signUpStack = UIStackView(arrangedSubviews: [ signUpLabel, signUpButton ])
    signUpStack.axis = .horizontal
    signUpStack.spacing = 8.0
    
    self.loginStack = loginStack
    self.loginTextFieldStack = loginTextFieldStack
    self.signUpStack = signUpStack
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    idTextField.snp.makeConstraints { make in
      make.height.equalTo(54)
    }
    
    pwTextField.snp.makeConstraints { make in
      make.height.equalTo(54)
    }
    
    idormMarkImage.snp.makeConstraints { make in
      make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(36)
    }
    
    loginTitleLabel.snp.makeConstraints { make in
      make.bottom.equalTo(loginStack.snp.top).offset(-10)
      make.leading.equalToSuperview().inset(36)
    }
    
    loginStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(36)
      make.bottom.equalTo(loginTextFieldStack.snp.top).offset(-54)
    }
    
    loginTextFieldStack.snp.makeConstraints { make in
      make.centerY.equalToSuperview().offset(-26)
      make.leading.trailing.equalToSuperview().inset(36)
    }
    
    loginButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(36)
      make.top.equalTo(loginTextFieldStack.snp.bottom).offset(32)
      make.height.equalTo(40)
    }
    
    forgotPwButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(loginButton.snp.bottom).offset(8)
    }
    
    signUpStack.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
    }
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // MARK: - Input
    
    // 이메일 텍스트 반응 감지
    idTextField.rx.text
      .orEmpty
      .bind(to: viewModel.input.emailTextFieldDidChange)
      .disposed(by: disposeBag)
    
    // 비밀번호 텍스트 반응 감지
    pwTextField.rx.text
      .orEmpty
      .bind(to: viewModel.input.passwordTextFieldDidChange)
      .disposed(by: disposeBag)
    
    // 로그인 버튼 클릭
    loginButton.rx.tap
      .bind(to: viewModel.input.loginButtonDidTap)
      .disposed(by: disposeBag)
    
    // 비밀번호 찾기 버튼 클릭
    forgotPwButton.rx.tap
      .bind(to: viewModel.input.forgotButtonDidTap)
      .disposed(by: disposeBag)
    
    // 회원가입 버튼 클릭
    signUpButton.rx.tap
      .bind(to: viewModel.input.signUpButtonDidTap)
      .disposed(by: disposeBag)
    
    // MARK: - Output
    
    // PutEmailVC
    viewModel.output.pushToPutEmailVC
      .bind(onNext: { [weak self] vcType in
        let putEmailVC = PutEmailViewController(vcType)
        self?.navigationController?.pushViewController(putEmailVC, animated: true)
      })
      .disposed(by: disposeBag)
    
    // 에러 팝업
    viewModel.output.presentPopupVC
      .bind(onNext: { [weak self] mention in
        let popupVC = BasicPopup(contents: mention)
        popupVC.modalPresentationStyle = .overFullScreen
        self?.present(popupVC, animated: false)
      })
      .disposed(by: disposeBag)
    
    // 메인화면으로 이동
    viewModel.output.presentTabBarVC
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        let tabBarVC = TabBarController()
        tabBarVC.modalPresentationStyle = .fullScreen
        self?.present(tabBarVC, animated: true)
      })
      .disposed(by: disposeBag)
    
    // 로딩 중
    viewModel.output.isLoading
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
  }
  
  
  // MARK: - Helpers
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}

