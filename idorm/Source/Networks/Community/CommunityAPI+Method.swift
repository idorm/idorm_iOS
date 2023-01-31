//
//  CommunityAPI+Method.swift
//  idorm
//
//  Created by 김응철 on 2023/01/27.
//

import Moya

extension CommunityAPI {
  func getMethod() -> Method {
    switch self {
    case .retrievePosts, .retrieveTopPosts, .retrievePost:
      return .get
      
    case .posting, .saveComment:
      return .post
    }
  }
}
