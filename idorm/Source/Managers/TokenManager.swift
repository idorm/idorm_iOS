//
//  TokenManager.swift
//  idorm
//
//  Created by 김응철 on 2023/05/06.
//

import Foundation

final class TokenManager {
  static let shared = TokenManager()
  
  var fcmToken: String?
}
