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
    case .getMatchingInfo: return .requestPlain
      
    case .createMatchingInfo(let request):
      return .requestJSONEncodable(request)
      
    case .updateMatchingInfo(let request):
      return .requestJSONEncodable(request)
      
    case .updateMatchingInfoForPublic(let isPublic):
      return .requestParameters(parameters: [
        "isMatchingInfoPublic": isPublic
      ], encoding: URLEncoding.queryString)
    }
  }
}
