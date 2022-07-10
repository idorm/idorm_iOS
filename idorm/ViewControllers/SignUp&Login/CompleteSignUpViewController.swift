//
//  CompleteSignUpViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/11.
//

import UIKit
import SnapKit

class CompleteSignUpViewController: UIViewController {
    // MARK: - Properties
    lazy var image: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "CompleteSignUp")
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    lazy var signUpLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "가입완료를 축하드려요!"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18.0, weight: .regular)
        
        return label
    }()
    
    lazy var continueButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("로그인 후 계속하기", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .mainColor
        button.layer.cornerRadius = 20.0
        button.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Selectors
    @objc private func didTapContinueButton() {
        
    }
    
    // MARK: - Helpers
    private func configureUI() {
        view.backgroundColor = .white
        
        let stack = UIStackView(arrangedSubviews: [ image, signUpLabel, continueButton ])
        stack.axis = .vertical
        stack.spacing = 70
        
        view.addSubview(stack)
        
        stack.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(80)
        }
        
        continueButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }
}
