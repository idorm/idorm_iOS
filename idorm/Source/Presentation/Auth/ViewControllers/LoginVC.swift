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
  
  // MARK: - UI COMPONENTS
  
  private let loginLabel = UILabel().then {
    $0.text = "로그인"
    $0.font = .idormFont(.bold, size: 24)
    $0.textColor = .black
  }
  
  private let loginDescriptionLabel = UILabel().then {
    $0.text = "인천대학교 이메일로 로그인해주세요."
    $0.textColor = .idorm_gray_400
    $0.font = .idormFont(.medium, size: 12)
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
    container.font = .idormFont(.medium, size: 14)
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
    container.font = .idormFont(.medium, size: 12)
    config.attributedTitle = AttributedString("비밀번호를 잊으셨나요?", attributes: container)
    $0.configuration = config
  }
  
  private let signUpLabel = UILabel().then {
    $0.text = "아직 계정이 없으신가요?"
    $0.textColor = .idorm_gray_300
    $0.font = .idormFont(.medium, size: 12)
  }
  
  private let signUpButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    var container = AttributeContainer()
    container.foregroundColor = UIColor.idorm_blue
    container.font = .idormFont(.medium, size: 12)
    config.attributedTitle = AttributedString("회원가입", attributes: container)
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    
    $0.configuration = config
  }
  
  private let indicator = UIActivityIndicatorView().then {
    $0.color = .darkGray
  }
  
  private lazy var loginStack = UIStackView().then { stack in
    [inuImageView, loginDescriptionLabel]
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
  
  private let idormimageView = UIImageView(image: #imageLiteral(resourceName: "idorm_gray"))
  private let inuImageView = UIImageView(image: #imageLiteral(resourceName: "inu"))
  
  //MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // TODO: 변화된 Storage에 따라서 초기화하기
//    TokenStorage.removeToken()
    FilterStorage.shared.resetFilter()
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
      .map { LoginViewReactor.Action.signIn($0.0, $0.1) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 회원가입 버튼 클릭
    signUpButton.rx.tap
      .map { LoginViewReactor.Action.signUp }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 비밀번호 찾기 버튼 클릭
    forgotPwButton.rx.tap
      .map { LoginViewReactor.Action.forgotPassword }
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
        SceneUtils.switchRootVC(to: tabBarVC, animated: true)
      }
      .disposed(by: self.disposeBag)
    
    // EmailVC로 이동
    reactor.state
      .map { $0.isOpenedPutEmailVC }
      .filter { $0.0 }
      .withUnretained(self)
      .bind { owner, type in
        let viewControllerType: EmailViewController.ViewControllerType
        switch type.1 {
        case .findPw:
          viewControllerType = .findPw
        case .signUp:
          viewControllerType = .signUp
        }
        let putEmailVC = EmailViewController(viewControllerType)
        putEmailVC.reactor = EmailViewReactor()
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
    [
      self.idormimageView,
      self.loginLabel,
      self.loginTfStack,
      self.loginStack,
      self.loginButton,
      self.forgotPwButton,
      self.signUpStack,
      self.indicator,
    ].forEach { self.view.addSubview($0) }
  }
  
  override func setupStyles() {
    super.setupStyles()
    self.view.backgroundColor = .white
    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  override func setupConstraints() {
    self.idormimageView.snp.makeConstraints { make in
      make.top.leading.equalTo(self.view.safeAreaLayoutGuide).inset(36)
    }
    
    self.loginLabel.snp.makeConstraints { make in
      make.bottom.equalTo(self.loginStack.snp.top).offset(-10)
      make.leading.equalToSuperview().inset(36)
    }
    
    self.loginStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(36)
      make.bottom.equalTo(self.loginTfStack.snp.top).offset(-54)
    }
    
    self.loginTfStack.snp.makeConstraints { make in
      make.centerY.equalToSuperview().offset(-26)
      make.leading.trailing.equalToSuperview().inset(36)
    }
    
    self.loginButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(36)
      make.top.equalTo(self.loginTfStack.snp.bottom).offset(32)
      make.height.equalTo(40)
    }
    
    self.forgotPwButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.loginButton.snp.bottom).offset(8)
    }
    
    self.signUpStack.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(16)
    }
    
    self.indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  // MARK: - Helpers
  
  override func touchesBegan(
    _ touches: Set<UITouch>,
    with event: UIEvent?
  ) {
    self.view.endEditing(true)
  }
}
