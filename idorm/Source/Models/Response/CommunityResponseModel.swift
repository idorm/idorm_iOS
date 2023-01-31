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
    let content: String
    let nickname: String?
    let profileUrl: String?
    let likesCount: Int
    let commentsCount: Int
    let imagesCount: Int
    let createdAt: String
    let updatedAt: String
    let photoUrls: [String]
    let comments: [Comment]
  }
  
  struct Comment: Codable, Equatable {
    let commentId: Int
    let parentCommentId: Int?
    let isDeleted: Bool
    let nickname: String?
    let profileUrl: String?
    let content: String
    let createdAt: String
  }
}
