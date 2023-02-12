//
//  CommentUtils.swift
//  idorm
//
//  Created by 김응철 on 2022/12/25.
//

enum CommentUtils {
  
  static func registeredComments(
    _ comments: [CommunityResponseModel.Comment]
  ) -> [OrderedComment] {
    var parentIds = [Int]()
    var orderedComments = [OrderedComment]()
    
    for i in comments {
      var currentComment = OrderedComment(comment: i, isLast: false, state: .normal)
      
      if let parentId = i.parentCommentId {
        
        if let lastIndex = orderedComments.lastIndex(
          where: { $0.comment.parentCommentId == parentId }
        ) {
          currentComment.state = .reply
          orderedComments.insert(currentComment, at: lastIndex + 1)
        } else if let lastIndex = orderedComments.lastIndex(
          where: { $0.comment.commentId == parentId }
        ) {
          currentComment.state = .firstReply
          orderedComments.insert(currentComment, at: lastIndex + 1)
        }
        
      } else {
        orderedComments.append(currentComment)
      }
    }
    
    parentIds = comments
      .filter { $0.parentCommentId != nil }
      .map { $0.parentCommentId! }
      .uniqued()

    orderedComments.indices.forEach {
      if parentIds.contains(orderedComments[$0].comment.commentId) == false {
        orderedComments[$0].isLast = true
      }
    }
    
    orderedComments.indices.forEach {
      if orderedComments[$0].comment.parentCommentId != nil {
        orderedComments[$0].isLast = false
      }
    }
    
    parentIds.forEach { parentId in
      if let lastIndex = orderedComments.lastIndex(
        where: { $0.comment.parentCommentId == parentId }
      ) {
        orderedComments[lastIndex].isLast = true
      }
    }
    
    return orderedComments
  }
}
