//
//  MatchingAPI+Method.swift
//  idorm
//
//  Created by 김응철 on 2023/01/31.
//

import Foundation

import Moya

extension MatchingMateAPI {
  func getMethod() -> Moya.Method{
    switch self {
    case .getMembers, .getLikedMembers, .getDislikedMembers:
      return .get
    case .createMatchingMate , .getFilteredMembers:
      return .post
    case .deleteMatchingMate:
      return .delete
    }
  }
}
