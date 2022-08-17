//
//  LoginManager.swift
//  idorm
//
//  Created by 김응철 on 2022/08/17.
//

import Foundation

class LoginStates {
  private init() {}
  static var currentLoginType: LoginType?
  static var currentEmail: String?
}
