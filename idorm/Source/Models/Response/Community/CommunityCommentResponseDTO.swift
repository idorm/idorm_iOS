//
//  CommunityCommentResponseDTO.swift
//  idorm
//
//  Created by 김응철 on 8/11/23.
//

import Foundation

struct CommunityCommentResponseDTO: Codable {
  let commentId: Int
  let memberId: Int?
  let content: String
  let createdAt: String
  let isDeleted: Bool
  let nickname: String?
  let profileUrl: String?
  let isAnonymous: Bool
  let postId: Int
  let subComments: [CommunitySubCommentResponseDTO]
}

extension Array where Element == CommunityCommentResponseDTO {
  /// `[CommunityCommentResponseDTO]`를
  /// 로컬에서 사용할 `[Comment]`로 변환해주는 메서드입니다.
  ///
  /// - returns:
  ///   - 새로운 `[Comment]` 리스트
  func toComments() -> [Comment] {
    var orderedComments = [Comment]()
    
    for comment in self {
      var orderedComment = Comment(
        content: comment.content,
        memberId: comment.memberId ?? -1,
        commentId: comment.commentId,
        isDeleted: comment.isDeleted,
        nickname: comment.nickname,
        profileUrl: comment.profileUrl,
        createdAt: comment.createdAt,
        isAnonymous: comment.isAnonymous,
        isLast: false,
        state: .normal(isRemoved: false)
      )
      
      if comment.subComments.isNotEmpty {
        var subComments = [Comment]()
        subComments = comment.subComments.map {
          return Comment(
            content: $0.content,
            memberId: $0.memberId ?? -1,
            commentId: $0.commentId,
            isDeleted: $0.isDeleted,
            nickname: $0.nickname,
            profileUrl: $0.profileUrl,
            createdAt: $0.createdAt,
            isAnonymous: $0.isAnonymous,
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
  
  /// `CommunitySubCommentResponseDTO`를
  /// `[Comment]` 리스트로 변환해주는 메서드입니다.
  ///
  /// - returns:
  ///   - `[Comment]` 리스트
  func arrangeSubComments(
    _ subComments: [Comment]
  ) -> [Comment] {
    var newComments = [Comment]()
    
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
