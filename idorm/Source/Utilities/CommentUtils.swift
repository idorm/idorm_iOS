//
//  CommentUtils.swift
//  idorm
//
//  Created by 김응철 on 2022/12/25.
//

enum CommentUtils {
  
  static func newestOrderedComments(
    _ comments: [CommunityResponseModel.Comment]
  ) -> [OrderedComment] {
    var orderedComments = [OrderedComment]()
    
    for (index, comment) in comments.enumerated() {
      var orderedComment = OrderedComment(
        content: comment.content,
        memberId: comment.memberId,
        commentId: comment.commentId,
        isDeleted: comment.isDeleted,
        nickname: comment.nickname,
        profileUrl: comment.profileUrl,
        createdAt: comment.createdAt,
        isLast: false,
        state: .normal
      )
      
      orderedComments.append(orderedComment)
      
      if comment.subComments.isNotEmpty {
        var subComments: [OrderedComment] = []
        subComments = comment.subComments.map {
          return OrderedComment(
            content: $0.content,
            memberId: $0.memberId,
            commentId: $0.commentId,
            isDeleted: $0.isDeleted,
            nickname: $0.nickname,
            profileUrl: $0.profileUrl,
            createdAt: $0.createdAt,
            isLast: false,
            state: .reply
          )
        }
        
        subComments[subComments.startIndex].state = .firstReply
        subComments[subComments.endIndex - 1].isLast = true
        orderedComments.append(contentsOf: subComments)
      } else {
        orderedComments[index].isLast = true
      }
    }

    return orderedComments
  }
}
