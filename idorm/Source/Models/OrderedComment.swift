//
//  OrderedComment.swift
//  idorm
//
//  Created by 김응철 on 2023/01/29.
//

import Foundation

struct OrderedComment {
  enum State {
    case reply
    case firstReply
    case normal
  }
  
  var comment: CommunityResponseModel.Comment
  var isLast: Bool
  var state: State
}
