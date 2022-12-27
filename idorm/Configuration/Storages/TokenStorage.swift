//
//  TokenStorage.swift
//  idorm
//
//  Created by 김응철 on 2022/12/19.
//

import Foundation

final class TokenStorage {
  
  static func saveToken(token: String) {
    let userDefaults = UserDefaults.standard
    userDefaults.set(token, forKey: "Token")
  }
  
  static func loadToken() -> String? {
    let userDefaults = UserDefaults.standard
    guard let token = userDefaults.string(forKey: "Token") else { return nil }
    return token
  }
  
  static func removeToken() {
    let userDefaults = UserDefaults.standard
    userDefaults.removeObject(forKey: "Token")
  }
  
  static func hasToken() -> Bool {
    loadToken() != nil ? true : false
  }
}
