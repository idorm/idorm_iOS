//
//  NetworkHeaderType.swift
//  idorm
//
//  Created by 김응철 on 9/23/23.
//

import Foundation

enum NetworkHeaderType {
  case normalJson
  case normalJsonWithoutToken
  case fcmJson
  case normalMultipart
  
  var header: [String: String] {
    switch self {
    case .normalJson:
      return [
        "Content-Type": "application/json",
        "Authorization": UserStorage.shared.token
      ]
    case .normalJsonWithoutToken:
      return ["Content-Type": "application/json"]
    case .fcmJson:
      return [
        "fcm-token": FCMTokenManager.shared.fcmToken!,
        "Content-Type": "application/json",
        "X-AUTH-TOKEN": UserStorage.shared.token
      ]
    case .normalMultipart:
      return [
        "Content-Type": "multipart/form-data",
        "Authorization": UserStorage.shared.token
      ]
    }
  }
}
