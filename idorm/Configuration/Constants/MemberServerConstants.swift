//
//  MemeberConstants.swift
//  idorm
//
//  Created by 김응철 on 2022/09/06.
//

final class MemberServerConstants {
  /// 로그인 요청 URL
  static let loginURL = ServerConstants.baseURL + "/login"
  /// 회원가입 요청 URL
  static let registerURL = ServerConstants.baseURL + "/register"
  /// 로그인이 되어 있지 않을 때, 비밀 번호 변경 요청 URL
  static let changePasswordURL = ServerConstants.baseURL + "/changepassword"
  /// 멤버 닉네임 변경 URL
  static let changeNicknameURL = ServerConstants.baseURL + "/member/nickname"
  /// 멤버 단건 조회 URL
  static let memberURL = ServerConstants.baseURL + "/member"
}
