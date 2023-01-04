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
  
  private lazy var loginStack = UIStackView().then { stack in
    [inuMarkImage, loginLabel]
      .forEach { stack.addArrangedSubview($0) }
    stack.axis = .horizontal
    stack.spacing = 8
  }
  
  private lazy var loginTfStack = UIStackView().then { stack in
    [idTextField, pwTextField]
      .forEach { stack.addArrangedSubview($0) }
    stack.axis = .vertical
    stack.distribution = .fillEqually
    stack.spacing = 10
  }
  
  private lazy var signUpStack = UIStackView().then { stack in
    [signUpLabel, signUpButton]
      .forEach { stack.addArrangedSubview($0) }
    stack.axis = .horizontal
    stack.spacing = 8
  }
  
  private let idormMarkImage = UIImageView(image: #imageLiteral(resourceName: "idorm_gray"))
  private let inuMarkImage = UIImageView(image: #imageLiteral(resourceName: "inu"))
  
  //MARK: - LifeCycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.isNavigationBarHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.isNavigationBarHidden = false
  }
  
  // MARK: - Bind
  
  func bind(reactor: LoginViewReactor) {
    
    // MARK: - Action
    
    // viewDidLoad
    rx.viewDidLoad
      .map { LoginViewReactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 로그인 버튼 클릭
    loginButton.rx.tap
      .withUnretained(self)
      .map { ($0.0.idTextField.text ?? "", $0.0.pwTextField.text ?? "") }
      .map { LoginViewReactor.Action.didTapLoginButton($0.0, $0.1) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 회원가입 버튼 클릭
    signUpButton.rx.tap
      .map { LoginViewReactor.Action.didTapSignupButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 비밀번호 찾기 버튼 클릭
    forgotPwButton.rx.tap
      .map { LoginViewReactor.Action.didTapForgotPwButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // MARK: - State
    
    // 메인VC로 이동
    reactor.state
      .map { $0.isOpenedMainVC }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let tabBarVC = TabBarViewController()
        tabBarVC.modalPresentationStyle = .fullScreen
        owner.present(tabBarVC, animated: true)
      }
      .disposed(by: disposeBag)
    
    // PutEmailVC로 이동
    reactor.state
      .map { $0.isOpenedPutEmailVC }
      .filter { $0.0 }
      .withUnretained(self)
      .bind { owner, type in
        let putEmailVC = PutEmailViewController(type.1)
        putEmailVC.reactor = PutEmailViewReactor()
        owner.navigationController?.pushViewController(putEmailVC, animated: true)
      }
      .disposed(by: disposeBag)
    
    // 인디케이터 제어
    reactor.state
      .map { $0.isLoading }
      .bind(to: indicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    // 화면 인터렉션 제어
    reactor.state
      .map { $0.isLoading }
      .map { !$0 }
      .bind(to: view.rx.isUserInteractionEnabled)
      .disposed(by: disposeBag)
    
    // 오류 팝업
    reactor.state
      .map { $0.isOpenedPopup }
      .filter { $0.0 }
      .withUnretained(self)
      .bind { owner, message in
        let popup = BasicPopup(contents: message.1)
        popup.modalPresentationStyle = .overFullScreen
        owner.present(popup, animated: false)
      }
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      idormMarkImage,
      loginTitleLabel,
      loginTfStack,
      loginStack,
      loginButton,
      forgotPwButton,
      signUpStack,
      indicator
    ]
      .forEach { view.addSubview($0) }
  }
  
  override func setupStyles() {
    super.setupStyles()
    
    view.backgroundColor = .white
    navigationController?.isNavigationBarHidden = true
    navigationController?.navigationBar.tintColor = .black
    navigationItem.title = "로그인"
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
      make.bottom.equalTo(loginTfStack.snp.top).offset(-54)
    }
    
    loginTfStack.snp.makeConstraints { make in
      make.centerY.equalToSuperview().offset(-26)
      make.leading.trailing.equalToSuperview().inset(36)
    }
    
    loginButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(36)
      make.top.equalTo(loginTfStack.snp.bottom).offset(32)
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
  
  // MARK: - Helpers
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}

