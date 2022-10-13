//
//  TokenManager.swift
//  idorm
//
//  Created by 김응철 on 2022/08/27.
//

import Foundation

class TokenManager {
  private init() {}
  
  static func saveToken(token: String) {
    let userDefaults = UserDefaults.standard
    userDefaults.set(token, forKey: "Token")
  }
  
  static func loadToken() -> String {
    let userDefaults = UserDefaults.standard
    guard let token = userDefaults.string(forKey: "Token") else { return "" }
    return token
  }
  
  static func removeToken() {
    let userDefaults = UserDefaults.standard
    userDefaults.removeObject(forKey: "Token")
  }
}
