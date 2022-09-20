//
//  LoginViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/10.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa

class LoginViewController: BaseViewController {
  // MARK: - Properties
  let loginTitleLabel = UILabel().then {
    $0.font = .init(name: MyFonts.bold.rawValue, size: 24)
    $0.text = "로그인"
  }
  
  let loginLabel = UILabel().then {
    $0.text = "인천대학교 이메일로 로그인해주세요."
    $0.textColor = .darkGray
    $0.font = .init(name: MyFonts.medium.rawValue, size: 12)
  }
  
  let idTextField = LoginTextField("이메일").then {
    $0.textContentType = .emailAddress
  }
  
  let pwTextField = LoginTextField("비밀번호").then {
    $0.keyboardType = .alphabet
    $0.isSecureTextEntry = true
  }
  
  let loginButton = UIButton().then {
    var config = UIButton.Configuration.filled()
    var container = AttributeContainer()
    container.font = .init(name: MyFonts.medium.rawValue, size: 14)
    container.foregroundColor = UIColor.white
    config.attributedTitle = AttributedString("로그인", attributes: container)
    config.baseBackgroundColor = .idorm_blue
    config.background.cornerRadius = 10
    
    $0.configuration = config
  }
  
  let forgotPwButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    var container = AttributeContainer()
    container.foregroundColor = UIColor.idorm_gray_300
    container.font = .init(name: MyFonts.medium.rawValue, size: 12)
    config.attributedTitle = AttributedString("비밀번호를 잊으셨나요?", attributes: container)
    
    $0.configuration = config
  }
  
  let signUpLabel = UILabel().then {
    $0.text = "아직 계정이 없으신가요?"
    $0.textColor = .idorm_gray_300
    $0.font = .init(name: MyFonts.medium.rawValue, size: FontSize.largeDescription.rawValue)
  }
  
  let signUpButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    var container = AttributeContainer()
    container.foregroundColor = UIColor.idorm_blue
    container.font = .init(name: MyFonts.medium.rawValue, size: 12)
    config.attributedTitle = AttributedString("회원가입", attributes: container)
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    
    $0.configuration = config
  }
  
  let idormMarkImage = UIImageView(image: UIImage(named: "i dorm Mark"))
  let inuMarkImage = UIImageView(image: UIImage(named: "INUMark"))
  var loginStack: UIStackView!
  var loginTextFieldStack: UIStackView!
  var signUpStack: UIStackView!
  
  let viewModel = LoginViewModel()
  
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
  override func bind() {
    super.bind()
    // ---------------------------------
    // ---------------INPUT-------------
    // ---------------------------------
    loginButton.rx.tap
      .throttle(.seconds(3), scheduler: MainScheduler.instance)
      .bind(to: viewModel.input.loginButtonTapped)
      .disposed(by: disposeBag)
    
    forgotPwButton.rx.tap
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .bind(to: viewModel.input.forgotButtonTapped)
      .disposed(by: disposeBag)
    
    signUpButton.rx.tap
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
      .bind(to: viewModel.input.signUpButtonTapped)
      .disposed(by: disposeBag)
    
    idTextField.rx.text
      .orEmpty
      .bind(to: viewModel.input.emailText)
      .disposed(by: disposeBag)
    
    pwTextField.rx.text
      .orEmpty
      .bind(to: viewModel.input.passwordText)
      .disposed(by: disposeBag)
    
//    rx.viewWillAppear
//      .map { _ in Void() }
//      .bind(onNext: { [weak self] in
//      })
//      .disposed(by: disposeBag)
    
    // ---------------------------------
    // --------------OUTPUT-------------
    // ---------------------------------
    viewModel.output.showPutEmailVC
      .bind(onNext: { [weak self] type in
        let putEmailVC = PutEmailViewController(type: type)
        self?.navigationController?.pushViewController(putEmailVC, animated: true)
      })
      .disposed(by: disposeBag)
    
    viewModel.output.showErrorPopupVC
      .asDriver(onErrorJustReturn: "")
      .drive(onNext: { [weak self] mention in
        let popupVC = PopupViewController(contents: mention)
        popupVC.modalPresentationStyle = .overFullScreen
        self?.present(popupVC, animated: false)
      })
      .disposed(by: disposeBag)
    
    viewModel.output.showTabBarVC
      .asDriver(onErrorJustReturn: Void())
      .drive(onNext: { [weak self] in
        let tabBarVC = TabBarController()
        tabBarVC.modalPresentationStyle = .fullScreen
        self?.present(tabBarVC, animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [idormMarkImage, loginTitleLabel, loginTextFieldStack, loginStack, loginButton, forgotPwButton, signUpStack]
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
      make.bottom.equalTo(loginStack.snp.top).offset(-8)
      make.leading.equalToSuperview().inset(36)
    }
    
    loginStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(36)
      make.bottom.equalTo(loginTextFieldStack.snp.top).offset(-54)
    }
    
    loginTextFieldStack.snp.makeConstraints { make in
      make.centerY.equalToSuperview().offset(-36)
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
  }
  
  // MARK: - Helpers
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}
