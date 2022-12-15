//
//  UserStorage.swift
//  idorm
//
//  Created by 김응철 on 2022/12/15.
//

import Foundation

class UserStorage {
  
  enum Keys: String {
    case email = "EMAIL"
    case password = "PASSWORD"
  }
  
  static func saveEmail(from email: String) {
    let userDefaults = UserDefaults.standard
    userDefaults.set(email, forKey: Keys.email.rawValue)
  }
  
  static func savePassword(from password: String) {
    let userDefaults = UserDefaults.standard
    userDefaults.set(password, forKey: Keys.password.rawValue)
  }
  
  static func loadEmail() -> String {
    let userDefaults = UserDefaults.standard
    return userDefaults.string(forKey: Keys.email.rawValue) ?? ""
  }
  
  static func loadPassword() -> String {
    let userDefaults = UserDefaults.standard
    return userDefaults.string(forKey: Keys.password.rawValue) ?? ""
  }
}
