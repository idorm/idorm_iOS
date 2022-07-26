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
        label.textColor = .darkgrey_custom
        label.text = "가입완료를 축하드려요!"
        label.textAlignment = .center
        label.font = .init(name: Font.bold.rawValue, size: 16.0)
        
        return label
    }()
    
    lazy var descriptionLabel1: UILabel = {
        let label = UILabel()
        label.font = .init(name: Font.medium.rawValue, size: 12.0)
        label.textColor = .grey_custom
        label.textAlignment = .center
        label.text = "로그인 후 인천대학교 기숙사 룸메이트 매칭을 위한"
        
        return label
    }()
    
    lazy var descriptionLabel2: UILabel = {
        let label = UILabel()
        label.font = .init(name: Font.medium.rawValue, size: 12.0)
        label.textColor = .grey_custom
        label.textAlignment = .center
        label.text = "기본정보를 알려주세요."
        
        return label
    }()
    
    lazy var continueButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("로그인 후 계속하기", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = .init(name: Font.medium.rawValue, size: 16.0)
        button.backgroundColor = .idorm_blue
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
        
        [ image, signUpLabel, descriptionLabel1, descriptionLabel2, continueButton ]
            .forEach { view.addSubview($0) }
        
        image.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(85)
            make.centerX.equalToSuperview()
        }
        
        signUpLabel.snp.makeConstraints { make in
            make.top.equalTo(image.snp.bottom).offset(70)
            make.centerX.equalToSuperview()
        }
        
        descriptionLabel1.snp.makeConstraints { make in
            make.top.equalTo(signUpLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        descriptionLabel2.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel1.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        
        continueButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(86)
            make.leading.trailing.equalToSuperview().inset(107.5)
            make.height.equalTo(44)
        }
    }
}
