//
//  CommunityAPI+Path.swift
//  idorm
//
//  Created by 김응철 on 2023/01/27.
//

import Foundation

extension CommunityAPI {
  func getPath() -> String {
    switch self {
    case .lookupPosts(let dorm, _):
      return "/member/posts/\(dorm.rawValue)"
      
    case .lookupTopPosts(let dorm):
      return "/member/posts/\(dorm.rawValue)/top"
      
    case .savePost:
      return "/member/post"
      
    case .lookupDetailPost(let postId):
      return "/member/post/\(postId)"
      
    case .saveComment(let postId, _):
      return "/member/post/\(postId)/comment"
      
    case .editPostSympathy(let postId, _):
      return "/member/post/\(postId)/like"
      
    case let .deleteComment(postId, commentId):
      return "/member/post/\(postId)/comment/\(commentId)"
      
    case .deletePost(let postId):
      return "/member/post/\(postId)"
    }
  }
}
