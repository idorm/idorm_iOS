//
//  CommunityAPI.swift
//  idorm
//
//  Created by 김응철 on 2023/01/14.
//

import Foundation

import Moya

enum CommunityAPI {
  case retrieveWithDorm(dorm: Dormitory, page: Int)
}

extension CommunityAPI: TargetType {
  var baseURL: URL {
    return URL(string: APIService.baseURL)!
  }
  
  var path: String {
    switch self {
    case .retrieveWithDorm(let dorm, _):
      return "/member/posts/\(dorm)"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .retrieveWithDorm:
      return .get
    }
  }
  
  var task: Moya.Task {
    switch self {
    case let .retrieveWithDorm(_, page):
      return .requestParameters(parameters: [
        "page": page
      ], encoding: URLEncoding.queryString)
    }
  }
  
  var headers: [String : String]? {
    APIService.basicHeader()
  }
}
