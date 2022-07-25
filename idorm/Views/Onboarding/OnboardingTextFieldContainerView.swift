//
//  TextFieldContainerView.swift
//  idorm
//
//  Created by 김응철 on 2022/07/16.
//

import UIKit
import SnapKit

class OnboardingTextFieldContainerView: UIView {
    // MARK: - Properties
    let placeholder: String
    
    lazy var textField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            NSAttributedString.Key.foregroundColor: UIColor.grey_custom,
            NSAttributedString.Key.font: UIFont.init(name: Font.medium.rawValue, size: 14.0) ?? 0
        ])
      tf.textColor = .black
        tf.font = .init(name: Font.medium.rawValue, size: 14.0)
        tf.addLeftPadding(16)
        tf.backgroundColor = .white
        tf.keyboardType = .default
        tf.returnKeyType = .done
        tf.delegate = self
        
        return tf
    }()
    
    lazy var checkmarkButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Checkmark"), for: .normal)
        button.isHidden = true
        
        return button
    }()
    
    lazy var xmarkButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Xmark_Grey"), for: .normal)
        button.addTarget(self, action: #selector(didTapXmarkButton), for: .touchUpInside)
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
    @objc private func didTapXmarkButton() {
        textField.text = ""
        xmarkButton.isHidden = true
        textField.becomeFirstResponder()
    }
    
    // MARK: - Helpers
    private func configureUI() {
        [ textField, checkmarkButton, xmarkButton ]
            .forEach { addSubview($0) }
        
        backgroundColor = .white
        layer.borderWidth = 1
        layer.cornerRadius = 10
        layer.borderColor = UIColor.grey_custom.cgColor
        
        textField.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(40)
        }
        
        checkmarkButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(8)
        }
        
        xmarkButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(8)
        }
    }
}

extension OnboardingTextFieldContainerView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textCount = textField.text?.count else { return true }
        if textCount > 25 {
            layer.borderColor = UIColor.red.cgColor
        } else {
            xmarkButton.isHidden = false
            layer.borderColor = UIColor.mainColor.cgColor
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let textCount = textField.text?.count else { return }
        if textCount > 25 {
            layer.borderColor = UIColor.red.cgColor
        } else {
            layer.borderColor = UIColor.mainColor.cgColor
            checkmarkButton.isHidden = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        xmarkButton.isHidden = true
        
        guard let count = textField.text?.count else { return }
        if count > 0 && count <= 25 {
            checkmarkButton.isHidden = false
        } else if count > 25 {
            layer.borderColor = UIColor.red.cgColor
            checkmarkButton.isHidden = true
        } else {
            layer.borderColor = UIColor.darkgrey_custom.cgColor
            checkmarkButton.isHidden = true
        }
    }
}
