//
//  CommunitySingleTopPostResponseDTO.swift
//  idorm
//
//  Created by 김응철 on 8/20/23.
//

import Foundation

struct CommunitySingleTopPostResponseDTO: Codable {
  let commentsCount: Int
  let content: String
  let dormCategory: Dormitory
  let imagesCount: Int
  let isAnonymous: Bool
  let likesCount: Int
  let memberId: Int
  let nickname: String?
  let postId: Int
  let title: String
  let updatedAt: String
  let createdAt: String
}
