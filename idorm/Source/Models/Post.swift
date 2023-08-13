//
//  Post.swift
//  idorm
//
//  Created by 김응철 on 8/11/23.
//

import Foundation

struct Post: Hashable {
  /// `postId`와 매칭
  let identifier: Int
  let memberIdentifier: Int
  let title: String
  let content: String
  let nickname: String?
  let profileURL: String?
  let likesCount: Int
  let commentsCount: Int
  let imagesCount: Int
  let isLiked: Bool
  let createdAt: String
  let updatedAt: String
  let isAnonymous: Bool
  let comments: [Comment]
  let photos: [PostPhoto]

  init(
    identifier: Int,
    memberIdentifier: Int,
    title: String,
    content: String,
    nickname: String?,
    profileURL: String?,
    likesCount: Int,
    commentsCount: Int,
    imagesCount: Int,
    isLiked: Bool,
    createdAt: String,
    updatedAt: String,
    isAnonymous: Bool,
    comments: [Comment],
    photos: [PostPhoto]
  ) {
    self.identifier = identifier
    self.memberIdentifier = memberIdentifier
    self.title = title
    self.content = content
    self.nickname = nickname
    self.profileURL = profileURL
    self.likesCount = likesCount
    self.commentsCount = commentsCount
    self.imagesCount = imagesCount
    self.isLiked = isLiked
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.isAnonymous = isAnonymous
    self.comments = comments
    self.photos = photos
  }

  /// `Mock`데이터를 생성할 수 있습니다.
  init() {
    self.identifier = -1
    self.memberIdentifier = -1
    self.title = ""
    self.content = ""
    self.nickname = ""
    self.profileURL = nil
    self.likesCount = 0
    self.commentsCount = 0
    self.imagesCount = 0
    self.isLiked = false
    self.createdAt = ""
    self.updatedAt = ""
    self.isAnonymous = false
    self.comments = []
    self.photos = []
  }
}

struct PostPhoto: Codable, Hashable {
  let photoID: Int
  let photoURL: String
}
