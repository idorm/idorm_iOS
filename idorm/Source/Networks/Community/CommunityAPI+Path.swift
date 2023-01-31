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
    case .retrievePosts(let dorm, _):
      return "/member/posts/\(dorm.rawValue)"
      
    case .retrieveTopPosts(let dorm):
      return "/member/posts/\(dorm.rawValue)/top"
      
    case .posting:
      return "/member/post"
      
    case .retrievePost(let postId):
      return "/member/post/\(postId)"
      
    case .saveComment(let postId, _):
      return "/member/post/\(postId)/comment"
    }
  }
}
