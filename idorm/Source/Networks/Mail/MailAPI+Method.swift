//
//  MailAPI+Method.swift
//  idorm
//
//  Created by 김응철 on 2023/01/31.
//

import Foundation

import Moya

extension MailAPI {
  func getMethod() -> Moya.Method {
    switch self {
    default: return .post
    }
  }
}
