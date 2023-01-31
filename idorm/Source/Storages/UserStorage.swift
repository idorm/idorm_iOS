//
//  UserStorage.swift
//  idorm
//
//  Created by 김응철 on 2022/12/15.
//

import Foundation

final class UserStorage {
  
  static let userDefaults = UserDefaults.standard
  
  private enum Keys: String {
    case email = "EMAIL"
    case password = "PASSWORD"
  }
  
  static func saveEmail(from email: String) {
    userDefaults.set(email, forKey: Keys.email.rawValue)
  }
  
  static func savePassword(from password: String) {
    userDefaults.set(password, forKey: Keys.password.rawValue)
  }
  
  static func loadEmail() -> String {
    return userDefaults.string(forKey: Keys.email.rawValue) ?? ""
  }
  
  static func loadPassword() -> String {
    return userDefaults.string(forKey: Keys.password.rawValue) ?? ""
  }
  
  static func reset() {
    userDefaults.removeObject(forKey: Keys.email.rawValue)
    userDefaults.removeObject(forKey: Keys.password.rawValue)
  }
}
