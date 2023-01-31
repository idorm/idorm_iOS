//
//  MatchingAPI+Task.swift
//  idorm
//
//  Created by 김응철 on 2023/01/31.
//

import Foundation

import Moya

extension MatchingAPI {
  func getTask() -> Task {
    switch self {
    case .retrieveFiltered(let filter):
      return .requestJSONEncodable(filter)
      
    default:
      return .requestPlain
    }
  }
}
