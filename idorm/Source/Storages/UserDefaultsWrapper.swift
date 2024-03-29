//
//  UserDefaultsWrapper.swift
//  idorm
//
//  Created by 김응철 on 2023/03/05.
//

import Foundation

@propertyWrapper
struct UserDefaultsWrapper<T: Codable> {

  private let key: String
  private let defaultValue: T

  init(key: String, defaultValue: T) {
    self.key = key
    self.defaultValue = defaultValue
  }

  var wrappedValue: T {
    get {
      guard let data = UserDefaults.standard.object(forKey: self.key) as? Data,
            let decodedData = try? JSONDecoder().decode(T.self, from: data) else {
        return defaultValue
      }
      return decodedData
    }
    set {
      guard let data = try? JSONEncoder().encode(newValue)
      else {
        UserDefaults.standard.removeObject(forKey: key)
        return
      }
      UserDefaults.standard.set(data, forKey: key)
    }
  }
}
