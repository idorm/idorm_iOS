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
    
    for comment in comments {
      var orderedComment = OrderedComment(
        content: comment.content,
        memberId: comment.memberId,
        commentId: comment.commentId,
        isDeleted: comment.isDeleted,
        nickname: comment.nickname,
        profileUrl: comment.profileUrl,
        createdAt: comment.createdAt,
        isLast: false,
        state: .normal(isRemoved: false)
      )
      
      if comment.subComments.isNotEmpty {
        var subComments = [OrderedComment]()
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
        
        switch comment.isDeleted {
        case true:
          // 대댓글들이 모두 삭제된 경우
          if comment.subComments.allSatisfy({ $0.isDeleted == true }) {
            break
          } else {
            orderedComment.state = .normal(isRemoved: true)
            orderedComments.append(orderedComment)
            orderedComments.append(contentsOf: arrangeSubComments(subComments))
          }
        case false:
          orderedComments.append(orderedComment)
          orderedComments.append(contentsOf: arrangeSubComments(subComments))
        }
      } else {
        orderedComment.isLast = true
        if !orderedComment.isDeleted {
          orderedComments.append(orderedComment)
        }
      }
    }
    
    return orderedComments
  }
  
  static func arrangeSubComments(
    _ subComments: [OrderedComment]
  ) -> [OrderedComment] {
    var newComments = [OrderedComment]()
    
    subComments.indices.forEach {
      if !subComments[$0].isDeleted {
        newComments.append(subComments[$0])
      }
    }
    
    if newComments.isNotEmpty {
      newComments[newComments.startIndex].state = .firstReply
      newComments[newComments.endIndex - 1].isLast = true
    }
    
    return newComments
  }
}
