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
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.text = "6자 이상의 비밀번호를 입력해주세요."
        label.textColor = .black
        label.font = .init(name: Font.medium.rawValue, size: 14.0)
        
        return label
    }()
    
    lazy var infoLabel2: UILabel = {
        let label = UILabel()
        label.text = "비밀번호 확인"
        label.textColor = .black
        label.font = .init(name: Font.medium.rawValue, size: 14.0)
        
        return label
    }()
    
    lazy var pwTextField: UITextField = {
        let tf = Utilites.returnTextField(placeholder: "비밀번호를 입력해주세요.")
        
        return tf
    }()
    
    lazy var pwTextField2: UITextField = {
        let tf = Utilites.returnTextField(placeholder: "비밀번호를 한번 더 입력해주세요.")
        tf.isSecureTextEntry = true
        
        return tf
    }()
    
    lazy var confirmButton: UIButton = {
        let button = Utilites.returnBottonConfirmButton(string: "")
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
        guard let password1 = pwTextField.text else { return }
        guard let password2 = pwTextField2.text else { return }
        
        infoLabel.textColor = .black
        infoLabel2.textColor = .black
        infoLabel2.text = "비밀번호 확인"
        
        if LoginType.isValidPassword(pwd: password1) == false {
            infoLabel.textColor = .red
        } else if password1 != password2 {
            infoLabel2.textColor = .red
            infoLabel2.text = "비밀번호가 일치하지 않습니다."
        } else {
            let completeVC = CompleteSignUpViewController()
            completeVC.modalPresentationStyle = .fullScreen
            present(completeVC, animated: true)
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
        
        [ infoLabel, infoLabel2, pwTextField, pwTextField2, confirmButton ]
            .forEach { view.addSubview($0) }
        
        infoLabel.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(52)
        }
        
        pwTextField.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        infoLabel2.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(pwTextField.snp.bottom).offset(42)
        }
        
        pwTextField2.snp.makeConstraints { make in
            make.top.equalTo(infoLabel2.snp.bottom).offset(8)
            make.trailing.leading.equalToSuperview().inset(24)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-20)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

