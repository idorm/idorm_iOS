//
//  FCMTokenManager.swift
//  idorm
//
//  Created by 김응철 on 8/26/23.
//

import Foundation
import OSLog

import Firebase
import FirebaseMessaging
import RxSwift

/// `Firebase`의 `FCM`토큰을 저장하고 관리하는 객체입니다.
final class FCMTokenManager {
  
  // MARK: - Properties
  
  static let shared = FCMTokenManager()
  var fcmToken: String?
    
  // MARK: - Functions
  
  /// `FCMToken`을 Firebase에 요청합니다.
  func requestFCMToken(_ completion: @escaping ((String) -> Void)) {
    Messaging.messaging().token { token, error in
      if let error = error {
        os_log(.error, "🔴 FCM 토큰을 요청하는 도중 에러가 발생했습니다. \(error.localizedDescription)")
      }
      if let token = token {
        os_log(.info, "🟢 FCM 토큰을 성공적으로 가져왔습니다.")
        self.fcmToken = token
        completion(token)
      }
    }
  }
}
