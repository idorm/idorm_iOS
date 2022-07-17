//
//  ConfirmPasswordViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/11.
//

import UIKit
import SnapKit

class ConfirmPasswordViewController: UIViewController {
    // MARK: - Properties
    let type: LoginType
    
    lazy var infoLabel = returnInfoLabel(text: "비밀번호")
    lazy var infoLabel2 = returnInfoLabel(text: "비밀번호 확인")
    
    lazy var eightLabel = returnDescriptionLabel(text: "•  8자 이상 입력")
    lazy var mixingLabel = returnDescriptionLabel(text: "•  영문 소문자/숫자/특수 문자 조합")
    
    lazy var passwordTextFieldContainerView: LoginPasswordTextFieldContainerView = {
        let containerView = LoginPasswordTextFieldContainerView(placeholder: "비밀번호를 입력해주세요.")
        containerView.textField.addTarget(self, action: #selector(textFieldDidChange), for: .allEditingEvents)
        containerView.textField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        containerView.textField.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        
        return containerView
    }()
    
    lazy var passwordTextFieldContainerView2: UITextField = {
        let tf = LoginUtilities.returnTextField(placeholder: "비밀번호를 한번 더 입력해주세요.")
        tf.addTarget(self, action: #selector(passwordTextFieldContainerView2_editingDidBegin(_:)), for: .editingDidBegin)
        tf.addTarget(self, action: #selector(passwordTextFieldContainerView2_EditingDidEnd(_:)), for: .editingDidEnd)
        tf.layer.borderColor = tf.isEditing ? UIColor.mainColor.cgColor : UIColor.darkgrey_custom.cgColor
        tf.isSecureTextEntry = true
        
        return tf
    }()
    
    lazy var confirmButton: UIButton = {
        let button = LoginUtilities.returnBottonConfirmButton(string: "")
        button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        
        if type == .singUp {
            button.setTitle("가입 완료", for: .normal)
        } else {
            button.setTitle("변경 완료", for: .normal)
        }
        
        return button
    }()
    
    // MARK: - LifeCycle
    init(type: LoginType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Selectors
    @objc private func didTapConfirmButton() {
//        guard let password1 = pwTextField.text else { return }
//        guard let password2 = pwTextField2.text else { return }
//
//        infoLabel.textColor = .black
//        infoLabel2.textColor = .black
//        infoLabel2.text = "비밀번호 확인"
//
//        if LoginType.isValidPassword(pwd: password1) == false {
//            infoLabel.textColor = .red
//        } else if password1 != password2 {
//            infoLabel2.textColor = .red
//            infoLabel2.text = "비밀번호가 일치하지 않습니다."
//        } else {
//            let completeVC = CompleteSignUpViewController()
//            completeVC.modalPresentationStyle = .fullScreen
//            present(completeVC, animated: true)
//        }
    }
    
    @objc private func textFieldDidChange(_ tf: UITextField) {
        if tf.text?.count ?? 0 >= 8 {
            eightLabel.textColor = .mainColor
        } else {
            eightLabel.textColor = .darkgrey_custom
        }
        
        if LoginUtilities.isValidPassword(pwd: tf.text ?? "") {
            mixingLabel.textColor = .mainColor
        } else {
            mixingLabel.textColor = .darkgrey_custom
        }
        
        validConfirmPassword(text: tf.text ?? "")
    }
    
    @objc private func textFieldDidEndEditing( tf: UITextField) {
        guard let text = tf.text else { return }
        if (text.count < 8) || (LoginUtilities.isValidPassword(pwd: text) == false) {
            infoLabel.textColor = .red
            passwordTextFieldContainerView.layer.borderColor = UIColor.red.cgColor
        }
        
        if text.count < 8 {
            eightLabel.textColor = .red
        }
        
        if LoginUtilities.isValidPassword(pwd: text) == false {
            mixingLabel.textColor = .red
        }
    }
    
    @objc private func textFieldDidBeginEditing(tf: UITextField) {
        infoLabel.textColor = .black
        eightLabel.textColor = .darkgrey_custom
        mixingLabel.textColor = .darkgrey_custom
        passwordTextFieldContainerView.layer.borderColor = UIColor.darkgrey_custom.cgColor
    }
    
    @objc private func passwordTextFieldContainerView2_editingDidBegin(_ tf: UITextField) {
        tf.layer.borderColor = UIColor.mainColor.cgColor
    }
    
    @objc private func passwordTextFieldContainerView2_EditingDidEnd(_ tf: UITextField) {
        tf.layer.borderColor = UIColor.darkgrey_custom.cgColor
        
        guard let password1Text = passwordTextFieldContainerView.textField.text else { return }
        if tf.text != password1Text {
            infoLabel2.text = "비밀번호가 일치하지 않습니다. 다시확인해주세요."
            infoLabel2.textColor = .red
            tf.layer.borderColor = UIColor.red.cgColor
        } else {
            infoLabel2.text = "비밀번호 확인"
            infoLabel2.textColor = .black
            tf.layer.borderColor = UIColor.darkgrey_custom.cgColor
        }
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        
        if type == .singUp {
            navigationItem.title = "회원가입"
        } else {
            navigationItem.title = "비밀번호 변경"
        }
        
        [ infoLabel, infoLabel2, passwordTextFieldContainerView, passwordTextFieldContainerView2, confirmButton, eightLabel, mixingLabel ]
            .forEach { view.addSubview($0) }
        
        infoLabel.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(52)
        }
        
        passwordTextFieldContainerView.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }
        
        eightLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextFieldContainerView.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(24)
        }
        
        mixingLabel.snp.makeConstraints { make in
            make.top.equalTo(eightLabel.snp.bottom)
            make.leading.equalToSuperview().inset(24)
        }
        
        infoLabel2.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(mixingLabel.snp.bottom).offset(30)
        }
        
        passwordTextFieldContainerView2.snp.makeConstraints { make in
            make.top.equalTo(infoLabel2.snp.bottom).offset(8)
            make.trailing.leading.equalToSuperview().inset(24)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-20)
        }
    }
    
    private func returnInfoLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .black
        label.font = .init(name: Font.medium.rawValue, size: 14.0)
        return label
    }
    
    private func returnDescriptionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.font = .init(name: Font.medium.rawValue, size: 12.0)
        label.textColor = .darkgrey_custom
        label.text = text
        
        return label
    }
    
    private func validConfirmPassword(text: String) {
        guard let password1Text = passwordTextFieldContainerView.textField.text else { return }
        if passwordTextFieldContainerView2.text != password1Text {
            infoLabel2.text = "비밀번호가 일치하지 않습니다. 다시확인해주세요."
            infoLabel2.textColor = .red
            passwordTextFieldContainerView2.layer.borderColor = UIColor.red.cgColor
        } else {
            infoLabel2.text = "비밀번호 확인"
            infoLabel2.textColor = .black
            passwordTextFieldContainerView2.layer.borderColor = UIColor.darkgrey_custom.cgColor
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
