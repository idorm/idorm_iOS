//
//  EmailConstants.swift
//  idorm
//
//  Created by 김응철 on 2022/09/07.
//

final class EmailConstants {
  /// 회원가입 이메일 인증 코드 전송
  static let emailAuthenticationURL: String = ServerConstants.baseURL + "/email"
  /// 비밀번호 변경 이메일 인증 코드 전송
  static let emailAuthentication_PasswordURL: String = ServerConstants.baseURL + "/email/password"
  /// 회원가입 이메일 인증 코드 검증
  static let verifyEmailCodeURL: String = ServerConstants.baseURL + "/verifyCode"
  /// 비밀번호 변경 이메일 인증 코드 검증
  static let verifyEmailCode_PasswordURL: String = ServerConstants.baseURL + "/verifyCode/password"
}
