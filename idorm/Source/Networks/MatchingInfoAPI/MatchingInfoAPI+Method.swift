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
    case .getMatchingInfo:
      return .get
    case .updateMatchingInfo:
      return .put
    case .createMatchingInfo:
      return .post
    case .updateMatchingInfoForPublic:
      return .patch
    }
  }
}
