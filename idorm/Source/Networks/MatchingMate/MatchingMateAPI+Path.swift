//
//  MatchingAPI+Path.swift
//  idorm
//
//  Created by 김응철 on 2023/01/31.
//

import Foundation

import Moya

extension MatchingMateAPI {
  func getPath() -> String {
    switch self {
    case .getMembers:
      return "/member/matching"
    case .getLikedMembers:
      return "/member/matching/like"
    case .createMatchingMate(_, let memberId), .deleteMatchingMate(_, let memberId):
      return "/member/matching/\(memberId)"
    case .getDislikedMembers:
      return "/member/matching/dislike"
    case .getFilteredMembers:
      return "/member/matching/filter"
    }
  }
}
