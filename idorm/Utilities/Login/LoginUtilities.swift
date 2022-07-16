//
//  ViewFactory.swift
//  idorm
//
//  Created by 김응철 on 2022/07/15.
//

import UIKit
import SnapKit

class LoginUtilities {
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
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
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
    
    static func isValidEmail(id: String) -> Bool {
           let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
           let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
           return emailTest.evaluate(with: id)
       }
       
    static func isValidPassword(pwd: String) -> Bool {
        let passwordRegEx = "^(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{0,}"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: pwd)
    }
    
    static func isValidPasswordFinal(pwd: String) -> Bool {
        let passwordRegEx = "^(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*()_+=-]).{8,20}"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: pwd)
    }

}
