//
//  MemeberConstants.swift
//  idorm
//
//  Created by 김응철 on 2022/09/06.
//

final class MemeberServerConstants {
  static let loginURL = ServerConstants.baseURL + "/login"
  static let memberURL = ServerConstants.baseURL + "/member"
  static let changeMemberNicknameURL = ServerConstants.baseURL + "/member/nickname"
  static let changeMemberPwURL = ServerConstants.baseURL + "/member/password"
  static let registerURL = ServerConstants.baseURL + "/register"
}
