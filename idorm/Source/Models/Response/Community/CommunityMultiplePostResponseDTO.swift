//
//  CommunityMultiplePostResponseDTO.swift
//  idorm
//
//  Created by 김응철 on 8/11/23.
//

import Foundation

struct CommunityMultiplePostResponseDTO: Decodable {
  let postId: Int
  let title: String
  let content: String
  let memberId: Int?
  let isAnonymous: Bool?
  let nickname: String?
  let commentsCount: Int
  let likesCount: Int
  let imagesCount: Int
  let createdAt: String
}
