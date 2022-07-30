//
//  LoginViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/10.
//

import UIKit
import SnapKit

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
    button.backgroundColor = .init(rgb: 0x582FFF)
    button.layer.cornerRadius = 10.0
    button.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
    
    return button
  }()
  
  lazy var forgotPwButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitle("비밀번호를 잊으셨나요?", for: .normal)
    button.titleLabel?.font = .init(name: Font.medium.rawValue, size: FontSize.largeDescription.rawValue)
    button.setTitleColor(UIColor.gray, for: .normal)
    button.addTarget(self, action: #selector(didTapForgotPwButton), for: .touchUpInside)
    
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
    button.setTitleColor(UIColor.init(rgb: 0x582FFF), for: .normal)
    button.titleLabel?.font = .init(name: Font.medium.rawValue, size: FontSize.largeDescription.rawValue)
    button.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
    
    return button
  }()
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
  }
  
  // MARK: - Selectors
  @objc private func didTapLoginButton() {
    guard let email = idTextField.text else { return }
    guard let password = pwTextField.text else { return }
    if LoginUtilities.isValidEmail(id: email) == false {
      let popupVC = LoginPopupViewController(contents: "이메일 형식을 확인해 주세요.")
      popupVC.modalPresentationStyle = .overFullScreen
      present(popupVC, animated: false)
    } else if LoginUtilities.isValidPassword(pwd: password) == false {
      let popupVC = LoginPopupViewController(contents: "비밀번호/아이디 확인 후 다시 시도해주세요.")
      popupVC.modalPresentationStyle = .overFullScreen
      present(popupVC, animated: false)
    } else {
      let popupVC = LoginPopupViewController(contents: "가입되지 않은 이메일 입니다.")
      popupVC.modalPresentationStyle = .overFullScreen
      present(popupVC, animated: false)
    }
  }
  
  @objc private func didTapForgotPwButton() {
    let putEmailVC = PutEmailViewController(type: .findPW)
    navigationController?.pushViewController(putEmailVC, animated: true)
  }
  
  @objc private func didTapSignUpButton() {
    let putEmailVC = PutEmailViewController(type: .singUp)
    navigationController?.pushViewController(putEmailVC, animated: true)
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

