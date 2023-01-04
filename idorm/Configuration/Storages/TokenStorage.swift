//
//  TokenStorage.swift
//  idorm
//
//  Created by 김응철 on 2022/12/19.
//

import Foundation

final class TokenStorage {
  
  static let key = "TOKEN"
  
  static func saveToken(token: String) {
    let userDefaults = UserDefaults.standard
    userDefaults.set(token, forKey: key)
  }
  
  static func loadToken() -> String? {
    let userDefaults = UserDefaults.standard
    guard let token = userDefaults.string(forKey: key) else { return nil }
    return token
  }
  
  static func removeToken() {
    let userDefaults = UserDefaults.standard
    userDefaults.removeObject(forKey: key)
  }
  
  static func hasToken() -> Bool {
    loadToken() != nil ? true : false
  }
}
