//
//  CommunitySinglePostResponseDTO.swift
//  idorm
//
//  Created by 김응철 on 8/11/23.
//

import Foundation

struct CommunitySinglePostResponseDTO: Codable {
  let postId: Int
  let memberId: Int
  let dormCategory: Dormitory
  let title: String
  let content: String
  let nickname: String?
  let profileUrl: String?
  let likesCount: Int
  let commentsCount: Int
  let imagesCount: Int
  let isLiked: Bool
  let createdAt: String
  let updatedAt: String
  let postPhotos: [CommunityPostPhotoResponseDTO]
  let comments: [CommunityCommentResponseDTO]
  let isAnonymous: Bool
}
