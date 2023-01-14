//
//  CommunityAPI.swift
//  idorm
//
//  Created by 김응철 on 2023/01/14.
//

import Foundation

import Moya

enum CommunityAPI {
  case retrievePosts(dorm: Dormitory, page: Int)
  case retrieveTopPosts(Dormitory)
}

extension CommunityAPI: TargetType {
  var baseURL: URL {
    return URL(string: APIService.baseURL)!
  }
  
  var path: String {
    switch self {
    case .retrievePosts(let dorm, _):
      return "/member/posts/\(dorm.rawValue)"
    case .retrieveTopPosts(let dorm):
      return "/member/posts/\(dorm.rawValue)/top"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .retrievePosts, .retrieveTopPosts:
      return .get
    }
  }
  
  var task: Moya.Task {
    switch self {
    case let .retrievePosts(_, page):
      return .requestParameters(parameters: [
        "page": page
      ], encoding: URLEncoding.queryString)
      
    case .retrieveTopPosts:
      return .requestPlain
    }
  }
  
  var headers: [String : String]? {
    APIService.basicHeader()
  }
}
