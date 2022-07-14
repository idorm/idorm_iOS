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
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10.0
        
        return view
    }()

    lazy var containerView2: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10.0
        
        return view
    }()
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.text = "6자 이상의 비밀번호를 입력해주세요."
        label.textColor = .black
        label.font = .systemFont(ofSize: 14.0)
        
        return label
    }()
    
    lazy var infoLabel2: UILabel = {
        let label = UILabel()
        label.text = "비밀번호 확인"
        label.textColor = .black
        label.font = .systemFont(ofSize: 14.0)
        
        return label
    }()
    
    lazy var pwTextField: UITextField = {
        let tf = UITextField()
        tf.textColor = .gray
        tf.addLeftPadding()
        tf.backgroundColor = .white
        tf.keyboardType = .alphabet
        tf.returnKeyType = .done
        tf.isSecureTextEntry = true
        
        if type == .findPW {
            tf.attributedPlaceholder = NSAttributedString(string: "새 비밀번호를 입력해주세요.", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        } else {
            tf.attributedPlaceholder = NSAttributedString(string: "비밀번호를 입력해주세요.", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        }
        
        return tf
    }()
    
    lazy var pwTextField2: UITextField = {
        let tf = UITextField()
        tf.textColor = .gray
        tf.addLeftPadding()
        tf.backgroundColor = .white
        tf.keyboardType = .alphabet
        tf.returnKeyType = .done
        tf.isSecureTextEntry = true
        
        if type == .findPW {
            tf.attributedPlaceholder = NSAttributedString(string: "새 비밀번호를 한번 더 입력해주세요.", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        } else {
            tf.attributedPlaceholder = NSAttributedString(string: "비밀번호를 한번 더 입력해주세요.", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        }
        
        return tf
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .mainColor
        button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        
        if type == .findPW {
            button.setTitle("변경 완료", for: .normal)
        } else {
            button.setTitle("가입 완료", for: .normal)
        }
        
        return button
    }()
    
    lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainColor
        
        return view
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
        
        containerView2.layer.borderColor = UIColor.black.cgColor
        containerView.layer.borderColor = UIColor.black.cgColor
        infoLabel.textColor = .black
        infoLabel2.textColor = .black
        infoLabel2.text = "비밀번호 확인"
        
        if LoginType.isValidPassword(pwd: password1) == false {
            containerView.layer.borderColor = UIColor.red.cgColor
            infoLabel.textColor = .red
        } else if password1 != password2 {
            containerView2.layer.borderColor = UIColor.red.cgColor
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
        
        containerView.addSubview(pwTextField)
        containerView2.addSubview(pwTextField2)
        
        pwTextField.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        pwTextField2.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        [ infoLabel, infoLabel2, containerView, containerView2, confirmButton, bottomView ]
            .forEach { view.addSubview($0) }
        
        infoLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(infoLabel.snp.bottom).offset(8)
            make.height.equalTo(60)
        }
        
        infoLabel2.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(containerView.snp.bottom).offset(24)
        }
        
        containerView2.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(infoLabel2.snp.bottom).offset(8)
            make.height.equalTo(60)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
            make.height.equalTo(65)
        }
        
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(confirmButton.snp.bottom)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

