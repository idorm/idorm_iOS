//
//  AuthViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/15.
//

import UIKit
import SnapKit

class AuthViewController: UIViewController {
    // MARK: - Properties
    var dismissCompletion: (() -> Void)?
    
    lazy var mailImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "mail")
        
        return iv
    }()
    
    lazy var authInfoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "AuthInfoLabel")
        
        return iv
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Xmark_Black"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var portalButton: UIButton = {
        let button = LoginUtilities.returnBottonConfirmButton(string: "메일함 바로가기")
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.init(rgb: 0xE3E1EC).cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(didTapPortalButton), for: .touchUpInside)
        
        return button
    }()
    
    lazy var confirmButton: UIButton = {
        let button = LoginUtilities.returnBottonConfirmButton(string: "인증번호 입력")
        button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Selectors
    @objc private func didTapBackButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapPortalButton() {
        
    }
    
    @objc private func didTapConfirmButton() {
        let authNumberVC = AuthNumberViewController(type: .singUp)
        navigationController?.pushViewController(authNumberVC, animated: true)
        
        authNumberVC.popCompletion = { [weak self] in
            guard let self = self else { return }
            self.dismissCompletion?()
            self.dismiss(animated: true)
        }
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        [ mailImageView, authInfoImageView, portalButton, confirmButton ]
            .forEach { view.addSubview($0) }
        
        mailImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(114)
            make.centerX.equalToSuperview()
        }
        
        authInfoImageView.snp.makeConstraints { make in
            make.top.equalTo(mailImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        confirmButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(85)
        }
        
        portalButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(confirmButton.snp.top).offset(-8)
        }
    }
}
