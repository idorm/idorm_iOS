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
    var newComments: [OrderedComment] = []
    
    for comment in comments {
      
      var orderedComment = OrderedComment(
        comment: comment,
        state: .normal
      )

      if let parentId = comment.parentCommentId {
        // 대댓글
        
        
        
        if let lastIndex = newComments.lastIndex(
          where: { $0.comment.commentId == parentId }
        ) {
          
          orderedComment.state = .reply
          newComments.insert(orderedComment, at: lastIndex + 1)
          
        }
        
      } else {
        // 댓글인 경우
        newComments.append(orderedComment)
      }
    }
    
    return newComments
  }
}
