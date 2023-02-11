//
//  MatchingAPI+Method.swift
//  idorm
//
//  Created by 김응철 on 2023/01/31.
//

import Foundation

import Moya

extension MatchingAPI {
  func getMethod() -> Moya.Method{
    switch self {
    case .lookupMembers, .lookupLikeMembers, .lookupDislikeMembers:
      return .get
    case .addMember , .lookupFilterMembers:
      return .post
    case .deleteMember:
      return .delete
    }
  }
}
