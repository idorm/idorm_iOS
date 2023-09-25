//
//  MatchingAPI+Task.swift
//  idorm
//
//  Created by 김응철 on 2023/01/31.
//

import Foundation

import Moya

extension MatchingMateAPI {
  func getTask() -> Task {
    switch self {
    case .getFilteredMembers(let filter):
      return .requestJSONEncodable(filter)
    case .createMatchingMate(let matchingType, _), .deleteMatchingMate(let matchingType, _):
      return .requestParameters(
        parameters: [
          "matchingType": String(matchingType)
      ],
        encoding: URLEncoding.queryString
      )
    default:
      return .requestPlain
    }
  }
}
