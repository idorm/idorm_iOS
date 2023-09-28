//
//  Post.swift
//  idorm
//
//  Created by 김응철 on 8/11/23.
//

import UIKit

struct Post: Hashable {
  /// `postId`와 매칭
  var identifier: Int
  var memberIdentifier: Int
  var dormCategory: Dormitory
  var title: String
  var content: String
  var nickname: String?
  var profileURL: String?
  var likesCount: Int
  var commentsCount: Int
  var imagesCount: Int
  var isLiked: Bool
  var createdAtPostList: String
  var createdAtPost: String
  var isAnonymous: Bool
  var comments: [Comment]
  var imagesData: [PostImageData]
  
  /// `Mock`데이터를 생성할 수 있습니다.
  init() {
    self.identifier = -1
    self.memberIdentifier = -1
    self.dormCategory = .no1
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
    self.imagesData = []
  }
  
  /// `CommunitySingleTopPostResponseDTO`를 받아서 변환할 수 있습니다.
  init(_ responseDTO: CommunitySingleTopPostResponseDTO) {
    self.identifier = responseDTO.postId
    self.memberIdentifier = responseDTO.memberId
    self.dormCategory = responseDTO.dormCategory
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
    self.imagesData = []
  }
  
  /// `CommunitySinglePostResponseDTO`를 받아서 변환할 수 있습니다.
  init(_ responseDTO: CommunitySinglePostResponseDTO) {
    self.identifier = responseDTO.postId
    self.memberIdentifier = responseDTO.memberId
    self.title = responseDTO.title
    self.dormCategory = responseDTO.dormCategory
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
    self.imagesData = responseDTO.postPhotos.map { PostImageData($0) }
  }
}
