//
//  CommunityCommentRequestModel.swift
//  idorm
//
//  Created by 김응철 on 8/12/23.
//

import Foundation

/// `CommunityAPI`에서 댓글 및 대댓글을 생성할 때 필요한 `RequestModel`입니다.

struct CommunityCommentRequestModel: Encodable {
  /// 댓글 내용
  let content: String
  /// 익명 여부
  let isAnonymous: Bool
  /// 부모 댓글
  let parentCommentId: Int
}
