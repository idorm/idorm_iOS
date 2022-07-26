//
//  LoginPasswordTextFieldContainerView.swift
//  idorm
//
//  Created by 김응철 on 2022/07/16.
//

import UIKit
import SnapKit

class LoginPasswordTextFieldContainerView: UIView {
    // MARK: - Properties
    let placeholder: String
    
    lazy var textField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.grey_custom,
            NSAttributedString.Key.font: UIFont.init(name: Font.medium.rawValue, size: 14.0) ?? 0
        ])
        tf.textColor = .grey_custom
        tf.font = .init(name: Font.medium.rawValue, size: 14.0)
        tf.addLeftPadding(16)
        tf.backgroundColor = .white
        tf.keyboardType = .default
        tf.returnKeyType = .done
        tf.isSecureTextEntry = true
        tf.delegate = self
        
        return tf
    }()
    
    lazy var openEyesButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "OpenEyes"), for: .normal)
        button.addTarget(self, action: #selector(didTapOpenEyesButton), for: .touchUpInside)
        button.isHidden = true
        
        return button
    }()
    
    lazy var closeEyesButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "CloseEyes"), for: .normal)
        button.addTarget(self, action: #selector(didTapCloseEyesButton), for: .touchUpInside)
        button.isHidden = true
        
        return button
    }()
    
    lazy var checkmarkButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Checkmark"), for: .normal)
        button.isHidden = true
        
        return button
    }()
    
    // MARK: - LifeCycle
    init(placeholder: String) {
        self.placeholder = placeholder
        super.init(frame: .zero)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    @objc private func didTapOpenEyesButton() {
        textField.isSecureTextEntry = false
        openEyesButton.isHidden = true
        closeEyesButton.isHidden = false
    }
    
    @objc private func didTapCloseEyesButton() {
        textField.isSecureTextEntry = true
        openEyesButton.isHidden = false
        closeEyesButton.isHidden = true
    }
    
    // MARK: - Helpers
    private func configureUI() {
        [ textField, openEyesButton, closeEyesButton, checkmarkButton ]
            .forEach { addSubview($0) }
        
        backgroundColor = .white
        layer.borderWidth = 1
        layer.cornerRadius = 10
        layer.borderColor = UIColor.darkgrey_custom.cgColor
        
        textField.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(40)
        }
        
        openEyesButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(8)
        }
        
        closeEyesButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(8)
        }
        
        checkmarkButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(8)
        }
    }
}

extension LoginPasswordTextFieldContainerView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        layer.borderColor = UIColor.idorm_blue.cgColor
        openEyesButton.isHidden = false
        checkmarkButton.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        openEyesButton.isHidden = true
        closeEyesButton.isHidden = true
        
        if LoginUtilities.isValidPasswordFinal(pwd: textField.text ?? "") {
            checkmarkButton.isHidden = false
            layer.borderColor = UIColor.darkgrey_custom.cgColor
        } else {
            checkmarkButton.isHidden = true
        }
    }
}
