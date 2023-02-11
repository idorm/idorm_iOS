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
    case .lookupFilterMembers(let filter):
      return .requestJSONEncodable(filter)
    case .addMember(let matchingType, _), .deleteMember(let matchingType, _):
      return .requestParameters(
        parameters: [
          "matchingType": matchingType
      ],
        encoding: URLEncoding.queryString
      )
    default:
      return .requestPlain
    }
  }
}
