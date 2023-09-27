//
//  Post.swift
//  idorm
//
//  Created by 김응철 on 8/11/23.
//

import Foundation

struct PostPhoto: Codable, Hashable {
  let photoID: Int
  let photoURL: String
}

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
  let createdAtPostList: String
  let createdAtPost: String
  let isAnonymous: Bool
  let comments: [Comment]
  let photos: [PostPhoto]

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
    self.createdAtPost = ""
    self.createdAtPostList = ""
    self.isAnonymous = false
    self.comments = []
    self.photos = []
  }
  
  /// `CommunitySingleTopPostResponseDTO`를 받아서 변환할 수 있습니다.
  init(_ responseDTO: CommunitySingleTopPostResponseDTO) {
    self.identifier = responseDTO.postId
    self.memberIdentifier = responseDTO.memberId
    self.title = responseDTO.title
    self.content = responseDTO.content
    self.nickname = responseDTO.nickname
    self.profileURL = nil
    self.likesCount = responseDTO.likesCount
    self.commentsCount = responseDTO.commentsCount
    self.imagesCount = responseDTO.imagesCount
    self.isLiked = false
    self.createdAtPost = responseDTO.createdAt.toPostFormatString(isPostList: false)
    self.createdAtPostList = responseDTO.createdAt.toPostFormatString(isPostList: true)
    self.isAnonymous = responseDTO.isAnonymous
    self.comments = []
    self.photos = []
  }
  
  /// `CommunitySinglePostResponseDTO`를 받아서 변환할 수 있습니다.
  init(_ responseDTO: CommunitySinglePostResponseDTO) {
    self.identifier = responseDTO.postId
    self.memberIdentifier = responseDTO.memberId
    self.title = responseDTO.title
    self.content = responseDTO.content
    self.nickname = responseDTO.nickname
    self.profileURL = responseDTO.profileUrl
    self.likesCount = responseDTO.likesCount
    self.commentsCount = responseDTO.commentsCount
    self.imagesCount = responseDTO.imagesCount
    self.isLiked = responseDTO.isLiked
    self.createdAtPost = responseDTO.createdAt.toPostFormatString(isPostList: false)
    self.createdAtPostList = responseDTO.createdAt.toPostFormatString(isPostList: true)
    self.isAnonymous = responseDTO.isAnonymous
    self.comments = responseDTO.comments.toComments()
    self.photos = responseDTO.postPhotos.toPostPhotos()
  }
}
