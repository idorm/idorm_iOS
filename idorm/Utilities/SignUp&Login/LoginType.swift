//
//  LoginType.swift
//  idorm
//
//  Created by 김응철 on 2022/07/11.
//

import Foundation

enum LoginType {
    case findPW
    case singUp
    
    static func isValidEmail(id: String) -> Bool {
           let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
           let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
           return emailTest.evaluate(with: id)
       }
       
    static func isValidPassword(pwd: String) -> Bool {
        let passwordRegEx = "^[a-zA-Z0-9]{6,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: pwd)
    }
}
