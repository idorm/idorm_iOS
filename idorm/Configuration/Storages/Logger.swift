//
//  Logger.swift
//  idorm
//
//  Created by 김응철 on 2022/12/19.
//

import Foundation

/// 회원가입을 할 떄, 임시적으로 유저의 정보를 저장하는 싱글톤 객체입니다.
final class Logger {
  
  static let shared = Logger()
  private init() {
    self.email = ""
    self.password = ""
    self.authenticationType = .password
  }
  
  private(set) var email: String
  private(set) var password: String
  private(set) var authenticationType: AuthenticationType
  
  func saveEmail(_ email: String) {
    self.email = email
  }
  
  func savePassword(_ password: String) {
    self.password = password
  }
  
  func saveAuthenticationType(_ authenticationType: AuthenticationType) {
    self.authenticationType = authenticationType
  }
}
