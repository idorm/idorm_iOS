//
//  MatchingInfoAPI+Method.swift
//  idorm
//
//  Created by 김응철 on 2023/01/31.
//

import Foundation

import Moya

extension MatchingInfoAPI {
  func getMethod() -> Moya.Method {
    switch self {
    case .retrieve: return .get
    case .modify: return .put
    case .save: return .post
    case .modifyPublic: return .patch
    }
  }
}
