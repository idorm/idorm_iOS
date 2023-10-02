//
//  Logger.swift
//  idorm
//
//  Created by 김응철 on 2022/12/19.
//

import Foundation

enum AuthProcess {
  case signUp
  case findPw
}

/// 회원가입을 할 떄, 임시적으로 유저의 정보를 저장하는 싱글톤 객체입니다.
final class Logger {
  
  static let shared = Logger()
  private init() {
    self.email = ""
    self.password = ""
    self.nickname = ""
    self.authProcess = .signUp
  }
  
  // MARK: - Properties
  
  private(set) var email: String
  private(set) var password: String
  private(set) var nickname: String
  private(set) var authProcess: AuthProcess
  private(set) var emailVC: AuthEmailViewController?
  
  // MARK: - HELPERS
  
  /// 이메일 정보를 저장합니다.
  func saveEmail(_ email: String) {
    self.email = email
  }
  
  /// 비밀번호 정보를 저장합니다.
  func savePassword(_ password: String) {
    self.password = password
  }
  
  /// 닉네임 정보를 저장합니다.
  func saveNickname(_ nickname: String) {
    self.nickname = nickname
  }
  
  /// 인증 타입에 대해 저장합니다.
  func saveAuthProcess(_ type: AuthProcess) {
    self.authProcess = type
  }
  
  /// 나중에 NavigationController Push를 위한 EmailVC의 참조값을 저장합니다.
  func saveEmailVcReference(_ vc: AuthEmailViewController) {
    self.emailVC = vc
  }
}
