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
  
  let comment: CommunityResponseModel.Comment
  var state: State
}
