//
//  CommunitySubCommentResponseDTO.swift
//  idorm
//
//  Created by 김응철 on 8/11/23.
//

import Foundation

struct CommunitySubCommentResponseDTO: Codable {
  let commentId: Int
  let parentCommentId: Int?
  let memberId: Int?
  let isDeleted: Bool
  let nickname: String?
  let profileUrl: String?
  let content: String
  let createdAt: String
  let isAnonymous: Bool
  let postId: Int?
}
