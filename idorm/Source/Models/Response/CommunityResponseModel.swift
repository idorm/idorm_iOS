//
//  CommunityResponseModel.swift
//  idorm
//
//  Created by 김응철 on 2023/01/27.
//

import Foundation

enum CommunityResponseModel {}

extension CommunityResponseModel {
  struct Posts: Codable, Equatable {
    let postId: Int
    let title: String
    let content: String
    let nickname: String?
    let commentsCount: Int
    let likesCount: Int
    let imagesCount: Int
    let createdAt: String
  }
  
  struct Post: Codable, Equatable {
    let postId: Int
    let title: String
    let memberId: Int
    let dormCategory: Dormitory
    let content: String
    let nickname: String?
    let profileUrl: String?
    let likesCount: Int
    let commentsCount: Int
    let imagesCount: Int
    let isLiked: Bool
    let createdAt: String
    let updatedAt: String
    let postPhotos: [PostPhotos]
    let comments: [Comment]
  }
  
  struct PostPhotos: Codable, Equatable {
    let photoId: Int
    let photoUrl: String
  }
  
  struct Comment: Codable, Equatable {
    let commentId: Int
    let memberId: Int
    let isDeleted: Bool
    let nickname: String?
    let profileUrl: String?
    let content: String
    let createdAt: String
    let subComments: [SubComment]
  }
  
  struct SubComment: Codable, Equatable {
    let commentId: Int
    let parentCommentId: Int
    let memberId: Int
    let isDeleted: Bool
    let nickname: String?
    let profileUrl: String?
    let content: String
    let createdAt: String
  }
}
