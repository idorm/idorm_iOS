//
//  CommunityAPI.swift
//  idorm
//
//  Created by 김응철 on 2023/01/14.
//

import Foundation

import Moya

enum CommunityAPI {
  case lookupPosts(dorm: Dormitory, page: Int)
  case lookupDetailPost(postId: Int)
  case lookupTopPosts(Dormitory)
  case lookupMyPosts
  case lookupMyLikedPosts
  case lookupMyComments
  case savePost(CommunityRequestModel.Post)
  case saveComment(postId: Int, body: CommunityRequestModel.Comment)
  case deleteComment(postId: Int, commentId: Int)
  case deletePost(postId: Int)
  case editPostSympathy(postId: Int, isSympathy: Bool)
  case editPost(
    postId: Int,
    post: CommunityRequestModel.Post,
    deletePostPhotos: [Int]
  )
}

extension CommunityAPI: TargetType, BaseAPI {
  static let provider = MoyaProvider<CommunityAPI>()
  
  var baseURL: URL { return getBaseURL() }
  var path: String { return getPath() }
  var method: Moya.Method { return getMethod() }
  var task: Moya.Task { return getTask() }
  var headers: [String : String]? {
    switch self {
    case .savePost:
      return getMultipartHeader()
    default:
      return getJsonHeader()
    }
  }
}
