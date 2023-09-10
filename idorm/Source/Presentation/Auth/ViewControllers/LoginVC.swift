//
//  LoginViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/21.
//

import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class LoginViewController: BaseViewController, View {
  
  typealias Reactor = LoginViewReactor
  
  // MARK: - UI Components
  
  /// `로그인`이 적혀있는 `UILabel`
  private let loginLabel: UILabel = {
    let label = UILabel()
    label.text = "로그인"
    label.font = .iDormFont(.bold, size: 24)
    label.textColor = .black
    return label
  }()
  
  /// `인천대학교 이메일로 로그인해주세요.`이 적혀있는 `UILabel`
  private let loginDescriptionLabel: UILabel = {
    let label = UILabel()
    label.text = "인천대학교 이메일로 로그인해주세요."
    label.textColor = .iDormColor(.iDormGray400)
    label.font = .iDormFont(.medium, size: 12.0)
    return label
  }()
  
  /// 아이디를 입력하는 `UITextField`
  private let emailTextField: NewiDormTextField = {
    let textField = NewiDormTextField(type: .login)
    textField.placeHolder = "이메일"
    textField.keyboardType = .emailAddress
    return textField
  }()
  
  /// 비밀번호를 입력하는 `UITextField`
  private let passwordTextField: NewiDormTextField = {
    let textField = NewiDormTextField(type: .login)
    textField.placeHolder = "비밀번호"
    textField.isSecureTextEntry = true
    return textField
  }()
  
  /// 로그인 `UIButton`
  private let loginButton: iDormButton = {
    let button = iDormButton("로그인", image: nil)
    button.baseBackgroundColor = .iDormColor(.iDormBlue)
    button.baseForegroundColor = .white
    button.font = .iDormFont(.medium, size: 14.0)
    button.cornerRadius = 12.0
    return button
  }()
  
  /// 비밀번호를 잊으셨나요? `UIButton`
  private let forgotPasswordButton: iDormButton = {
    let button = iDormButton("비밀번호를 잊으셨나요?", image: nil)
    button.baseBackgroundColor = .clear
    button.baseForegroundColor = .iDormColor(.iDormGray300)
    button.font = .iDormFont(.medium, size: 12.0)
    button.contentInset = .zero
    return button
  }()
  
  /// 아직 계정이 없으신가요? `UILabel`
  private let stillDontHaveAccountLabel: UILabel = {
    let label = UILabel()
    label.text = "비밀번호를 잊으셨나요?"
    label.textColor = .iDormColor(.iDormGray300)
    label.font = .iDormFont(.medium, size: 12.0)
    return label
  }()
  
  /// 회원가입 `UIButton`
  private let signUpButton: iDormButton = {
    let button = iDormButton("회원가입", image: nil)
    button.baseForegroundColor = .iDormColor(.iDormBlue)
    button.baseBackgroundColor = .clear
    button.font = .iDormFont(.medium, size: 12.0)
    button.contentInset = .zero
    return button
  }()
  
  private lazy var signUpStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [
      self.stillDontHaveAccountLabel, self.signUpButton
    ])
    stackView.axis = .horizontal
    stackView.spacing = 6.0
    return stackView
  }()
  
  /// ic_inu인 `UIImageView`
  private let inuImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .iDormIcon(.inu)
    return imageView
  }()
  
  /// ic_idorm인 `UIImageView`
  private let iDormImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .iDormIcon(.idorm)
    return imageView
  }()
  
  //MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // TODO: 변화된 Storage에 따라서 초기화하기
    FilterStorage.shared.resetFilter()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  // MARK: - Bind
  
  func bind(reactor: LoginViewReactor) {
    
    // Action
    
    self.loginButton.rx.tap
      .map { Reactor.Action.loginButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.emailTextField.text
      .map { Reactor.Action.emailTextFieldDidChange($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.passwordTextField.text
      .map { Reactor.Action.passwordTextFieldDidChange($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.signUpButton.rx.tap
      .map { Reactor.Action.signUpButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.forgotPasswordButton.rx.tap
      .map { Reactor.Action.forgotPasswordButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    
    reactor.pulse(\.$shouldPresentToTabBarVC)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        let viewController = TabBarViewController()
        owner.present(viewController, animated: true)
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$shouldNavigateToEmailVC)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, authProcess in
        guard let authProcess = authProcess else { return }
        let viewController = EmailViewController()
        switch authProcess {
        case .findPw:
          viewController.reactor = EmailViewReactor(.findPassword)
        case .signUp:
          viewController.reactor = EmailViewReactor(.signUp)
        }
        owner.navigationController?.pushViewController(viewController, animated: true)
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    self.view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [
      self.iDormImageView,
      self.loginLabel,
      self.loginDescriptionLabel,
      self.inuImageView,
      self.emailTextField,
      self.passwordTextField,
      self.loginButton,
      self.forgotPasswordButton,
      self.signUpStackView
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.iDormImageView.snp.makeConstraints { make in
      make.top.equalTo(self.view.safeAreaLayoutGuide).inset(40.0)
      make.leading.equalToSuperview().inset(36.0)
    }
    
    self.loginLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(36.0)
      make.bottom.equalTo(self.inuImageView.snp.top).offset(-10.0)
    }
    
    self.inuImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(36.0)
      make.bottom.equalTo(self.emailTextField.snp.top).offset(-56.0)
    }
    
    self.loginDescriptionLabel.snp.makeConstraints { make in
      make.leading.equalTo(self.inuImageView.snp.trailing).offset(6.0)
      make.centerY.equalTo(self.inuImageView)
    }
    
    self.emailTextField.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(36.0)
      make.bottom.equalTo(self.passwordTextField.snp.top).offset(-10.0)
    }

    self.passwordTextField.snp.makeConstraints { make in
      make.centerY.equalTo(self.view.safeAreaLayoutGuide).offset(-10.0)
      make.directionalHorizontalEdges.equalToSuperview().inset(36.0)
    }
    
    self.loginButton.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(36.0)
      make.top.equalTo(self.passwordTextField.snp.bottom).offset(32.0)
      make.height.equalTo(40.0)
    }
    
    self.forgotPasswordButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.loginButton.snp.bottom)
    }
    
    self.signUpStackView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(48.0)
    }
  }
  
  // MARK: - Fucntions
  
  override func touchesBegan(
    _ touches: Set<UITouch>,
    with event: UIEvent?
  ) {
    self.view.endEditing(true)
  }
}
