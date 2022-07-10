//
//  FindPasswordViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/10.
//

import UIKit
import SnapKit

class PutEmailViewController: UIViewController {
    // MARK: - Properties
    let type: LoginType
    var confirmButtonYValue = CGFloat(0)
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        if type == .findPW {
            label.text = "가입시 사용한 인천대학교 이메일이 필요해요."
        } else {
            label.text = "이메일"
        }
        
        return label
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10.0
        
        return view
    }()
    
    lazy var emailTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "이메일을 입력해주세요.", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        tf.textColor = .gray
        tf.addLeftPadding()
        tf.backgroundColor = .white
        tf.keyboardType = .emailAddress
        tf.returnKeyType = .done
        
        return tf
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        button.backgroundColor = .mainColor
        if type == .findPW {
            button.setTitle("인증번호 발급받기", for: .normal)
        } else {
            button.setTitle("회원가입", for: .normal)
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
        let authVC = AuthNumberViewController(type: type)
        let navVC = UINavigationController(rootViewController: authVC)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
        
        authVC.dismissCompletion = { [weak self] confirmPwVC in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                guard let self = self else { return }
                self.navigationController?.pushViewController(confirmPwVC, animated: true)
            }
        }
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = false
        
        if type == .findPW {
            navigationItem.title = "비밀번호 찾기"
        } else {
            navigationItem.title = "회원가입"
        }
        
        containerView.addSubview(emailTextField)
        
        [ infoLabel, containerView, confirmButton, bottomView ]
            .forEach { view.addSubview($0) }
        
        emailTextField.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        infoLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
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
