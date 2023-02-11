//
//  MatchingAPI+Path.swift
//  idorm
//
//  Created by 김응철 on 2023/01/31.
//

import Foundation

import Moya

extension MatchingAPI {
  func getPath() -> String {
    switch self {
    case .lookupMembers:
      return "/member/matching"
    case .lookupLikeMembers:
      return "/member/matching/like"
    case .addMember(_, let memberId), .deleteMember(_, let memberId):
      return "/member/matching/\(memberId)"
    case .lookupDislikeMembers:
      return "/member/matching/dislike"
    case .lookupFilterMembers:
      return "/member/matching/filter"
    }
  }
}
