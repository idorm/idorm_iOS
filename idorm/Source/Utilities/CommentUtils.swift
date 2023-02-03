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
        if let lastIndex = newComments.lastIndex(where: {
          $0.comment.parentCommentId == parentId
        }) {
          // MARK: - 두 번째 대댓글
          orderedComment.state = .reply
          newComments.insert(orderedComment, at: lastIndex + 1)
        } else {
          // MARK: - 첫 번째 대댓글
          guard let lastIndex = newComments.lastIndex(where: {
            $0.comment.commentId == parentId
          }) else {
            return []
          }
          
          orderedComment.state = .firstReply
          newComments.insert(orderedComment, at: lastIndex + 1)
        }
        
      } else {
        // MARK: - 일반 댓글
        newComments.append(orderedComment)
      }
    }
    
    return newComments
  }
}
