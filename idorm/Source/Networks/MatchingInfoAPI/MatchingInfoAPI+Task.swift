//
//  MatchingInfoAPI+Task.swift
//  idorm
//
//  Created by 김응철 on 2023/01/31.
//

import Foundation

import Moya

extension MatchingInfoAPI {
  func getTask() -> Task {
    switch self {
    case .retrieve: return .requestPlain
      
    case .save(let request), .modify(let request):
      return .requestJSONEncodable(request)
      
    case .modifyPublic(let isPublic):
      return .requestParameters(parameters: [
        "isMatchingInfoPublic": isPublic
      ], encoding: URLEncoding.queryString)
    }
  }
}
