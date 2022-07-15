//
//  ViewFactory.swift
//  idorm
//
//  Created by 김응철 on 2022/07/15.
//

import UIKit
import SnapKit

class Utilites {
    // MARK: - Login View
    static func returnLoginTextField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.gray,
                NSAttributedString.Key.font: UIFont.init(name: Font.regular.rawValue, size: FontSize.main.rawValue) ?? 0
            ])
        tf.textColor = .gray
        tf.backgroundColor = .init(rgb: 0xF4F2FA)
        tf.font = .init(name: Font.regular.rawValue, size: FontSize.main.rawValue)
        tf.layer.cornerRadius = 15.0
        tf.addLeftPadding(16)
        
        return tf
    }
    
    // MARK: - SignUp&Login
    static func returnBottonConfirmButton(string: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = .mainColor
        button.layer.cornerRadius = 10.0
        button.setTitle(string, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = .init(name: Font.regular.rawValue, size: 14.0)
        button.snp.makeConstraints { make in
            make.height.equalTo(50.0)
        }
        
        return button
    }
    
    static func returnTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.attributedPlaceholder =
        NSAttributedString(
            string: placeholder,
            attributes:
                [
                    NSAttributedString.Key.foregroundColor: UIColor.gray,
                    NSAttributedString.Key.font: UIFont.init(name: Font.medium.rawValue, size: 14.0 ) ?? 0
                ])
        textField.textColor = .gray
        textField.addLeftPadding(14)
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 10
        textField.returnKeyType = .done
        textField.font = .init(name: Font.medium.rawValue, size: 14.0)
        
        textField.snp.makeConstraints { make in
            make.height.equalTo(50.0)
        }
        
        return textField
    }
}

