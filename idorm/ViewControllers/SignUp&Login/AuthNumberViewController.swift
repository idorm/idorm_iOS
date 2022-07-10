//
//  AuthNumberViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/10.
//

import UIKit
import SnapKit

class AuthNumberViewController: UIViewController {
    // MARK: - Properties
    let type: LoginType
    var dismissCompletion: ((UIViewController) -> Void)?
    
    lazy var mailImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "mail")
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.text = "지금 이메일로 인증번호를 보내드렸어요!"
        label.textColor = .black
        label.font = .systemFont(ofSize: 14.0)
        
        return label
    }()
    
    lazy var requestAgainButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("인증번호 재요청", for: .normal)
        button.setTitleColor(UIColor.gray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14.0)
        button.addTarget(self, action: #selector(didTapRequestButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10.0
        
        return view
    }()
    
    lazy var authNumberTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "인증번호를 입력해주세요.", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        tf.textColor = .gray
        tf.addLeftPadding()
        tf.backgroundColor = .white
        tf.keyboardType = .emailAddress
        tf.returnKeyType = .done
        
        return tf
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("인증 완료", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .mainColor
        button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(didTapDismissButton), for: .touchUpInside)
        button.tintColor = .black
        
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
    @objc private func didTapDismissButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapRequestButton() {
        
    }
    
    @objc private func didTapConfirmButton() {
        let confirmPwVC = ConfirmPasswordViewController(type: type)
        dismiss(animated: false)
        dismissCompletion?(confirmPwVC)
    }
    
    // MARK: - Helpers
    private func configureUI() {
        navigationItem.title = "인증번호 입력"
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
        
        view.backgroundColor = .white
        containerView.addSubview(authNumberTextField)
        
        authNumberTextField.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        [ mailImageView, infoLabel, requestAgainButton, containerView, confirmButton, bottomView ]
            .forEach { view.addSubview($0) }
        
        mailImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.equalTo(mailImageView.snp.bottom).offset(40)
        }
        
        requestAgainButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.centerY.equalTo(infoLabel)
        }
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(infoLabel.snp.bottom).offset(16)
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
