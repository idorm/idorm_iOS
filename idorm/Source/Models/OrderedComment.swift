//
//  OrderedComment.swift
//  idorm
//
//  Created by 김응철 on 2023/01/29.
//

import Foundation

struct OrderedComment {
  enum CommentState {
    case reply
    case firstReply
    case normal(isRemoved: Bool)
  }
  let content: String
  let memberId: Int
  let commentId: Int
  var isDeleted: Bool
  let nickname: String?
  let profileUrl: String?
  let createdAt: String
  var isLast: Bool
  var state: CommentState
}
