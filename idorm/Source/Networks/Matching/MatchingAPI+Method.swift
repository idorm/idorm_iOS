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
    case .retrieve, .retrieveLiked, .retrieveDisliked:
      return .get
    case .addLiked, .addDisliked, .retrieveFiltered:
      return .post
    case .deleteLiked, .deleteDisliked:
      return .delete
    }
  }
}
