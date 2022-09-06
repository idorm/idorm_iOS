//
//  LoginViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/10.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
  // MARK: - Properties
  lazy var idormMarkImage: UIImageView = {
    let iv = UIImageView()
    iv.image = UIImage(named: "i dorm Mark")
    iv.contentMode = .scaleAspectFit
    
    return iv
  }()
  
  lazy var loginTitleLabel: UILabel = {
    let label = UILabel()
    label.font = .init(name: Font.bold.rawValue, size: 24)
    label.text = "로그인"
    label.textColor = .black
    
    return label
  }()
  
  lazy var INU_Mark: UIImageView = {
    let iv = UIImageView()
    iv.image = UIImage(named: "INUMark")
    iv.contentMode = .scaleAspectFit
    
    return iv
  }()
  
  lazy var loginLabel: UILabel = {
    let label = UILabel()
    label.text = "인천대학교 이메일로 로그인해주세요."
    label.textColor = .darkGray
    label.font = .init(name: Font.medium.rawValue, size: 12)
    
    return label
  }()
  
  lazy var idTextField: UITextField = {
    let tf = returnLoginTextField(placeholder: "이메일")
    tf.keyboardType = .emailAddress
    
    return tf
  }()
  
  lazy var pwTextField: UITextField = {
    let tf = returnLoginTextField(placeholder: "비밀번호")
    tf.keyboardType = .alphabet
    tf.isSecureTextEntry = true
    
    return tf
  }()
  
  lazy var loginButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitle("로그인", for: .normal)
    button.setTitleColor(UIColor.white, for: .normal)
    button.titleLabel?.font = .init(name: Font.medium.rawValue, size: 14)
    button.backgroundColor = .idorm_blue
    button.layer.cornerRadius = 10.0
    
    return button
  }()
  
  lazy var forgotPwButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitle("비밀번호를 잊으셨나요?", for: .normal)
    button.titleLabel?.font = .init(name: Font.medium.rawValue, size: FontSize.largeDescription.rawValue)
    button.setTitleColor(UIColor.gray, for: .normal)
    
    return button
  }()
  
  lazy var signUpLabel: UILabel = {
    let label = UILabel()
    label.text = "아직 계정이 없으신가요?"
    label.textColor = .gray
    label.font = .init(name: Font.medium.rawValue, size: FontSize.largeDescription.rawValue)
    
    return label
  }()
  
  lazy var signUpButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitle("회원가입", for: .normal)
    button.setTitleColor(UIColor.idorm_blue, for: .normal)
    button.titleLabel?.font = .init(name: Font.medium.rawValue, size: FontSize.largeDescription.rawValue)
    
    return button
  }()
  
  let viewModel = LoginViewModel()
  let disposeBag = DisposeBag()
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bind()
  }
  
  // MARK: - Bind
  func bind() {
    // ---------------------------------
    // ---------------INPUT-------------
    // ---------------------------------
    loginButton.rx.tap
      .throttle(.seconds(1), scheduler: MainScheduler.instance)
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
    
    rx.viewWillAppear
      .map { _ in Void() }
      .bind(onNext: { [weak self] in
        self?.navigationController?.isNavigationBarHidden = true
      })
      .disposed(by: disposeBag)
    
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
  
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .white
    navigationController?.isNavigationBarHidden = true
    navigationController?.navigationBar.tintColor = .black
    navigationItem.title = "로그인"
    
    let loginStack = UIStackView(arrangedSubviews: [ INU_Mark, loginLabel ])
    loginStack.axis = .horizontal
    loginStack.spacing = 8.0
    
    let loginTextFieldStack = UIStackView(arrangedSubviews: [ idTextField, pwTextField ])
    loginTextFieldStack.axis = .vertical
    loginTextFieldStack.distribution = .fillEqually
    loginTextFieldStack.spacing = 10.0
    
    idTextField.snp.makeConstraints { make in
      make.height.equalTo(54)
    }
    
    pwTextField.snp.makeConstraints { make in
      make.height.equalTo(54)
    }
    
    let signUpStack = UIStackView(arrangedSubviews: [ signUpLabel, signUpButton ])
    signUpStack.axis = .horizontal
    signUpStack.spacing = 8.0
    
    [ idormMarkImage, loginTitleLabel, loginTextFieldStack, loginStack, loginButton, forgotPwButton, signUpStack ]
      .forEach { view.addSubview($0) }
    
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
  
  private func returnLoginTextField(placeholder: String) -> UITextField {
    let tf = UITextField()
    tf.attributedPlaceholder = NSAttributedString(
      string: placeholder,
      attributes: [
        NSAttributedString.Key.foregroundColor: UIColor.gray,
        NSAttributedString.Key.font: UIFont.init(name: Font.regular.rawValue, size: FontSize.main.rawValue) ?? 0
      ])
    tf.textColor = .gray
    tf.backgroundColor = .init(rgb: 0xF4F2FA)
    tf.font = .init(name: Font.regular.rawValue, size: FontSize.main.rawValue)
    tf.layer.cornerRadius = 15.0
    tf.addLeftPadding(16)
    
    return tf
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}
