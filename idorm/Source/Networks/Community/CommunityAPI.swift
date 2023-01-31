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
  case retrievePost(postId: Int)
  case retrieveTopPosts(Dormitory)
  case posting(CommunityRequestModel.Post)
  case saveComment(postId: Int, body: CommunityRequestModel.Comment)
}

extension CommunityAPI: TargetType, BaseAPI {
  static let provider = MoyaProvider<CommunityAPI>()
  
  var baseURL: URL { return getBaseURL() }
  var path: String { return getPath() }
  var method: Moya.Method { return getMethod() }
  var task: Moya.Task { return getTask() }
  var headers: [String : String]? {
    switch self {
    case .posting:
      return getMultipartHeader()
    default:
      return getJsonHeader()
    }
  }
}
