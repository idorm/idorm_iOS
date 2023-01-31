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
    case .retrieve:
      return "/member/matching"
    case .retrieveLiked:
      return "/member/matching/like"
    case .addLiked(let id), .deleteLiked(let id):
      return "/member/matching/like/\(id)"
    case .addDisliked(let id), .deleteDisliked(let id):
      return "/member/matching/dislike/\(id)"
    case .retrieveDisliked:
      return "/member/matching/dislike"
    case .retrieveFiltered:
      return "/member/matching/filter"
    }
  }
}
