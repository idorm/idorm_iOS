//
//  CommunityDTO.swift
//  idorm
//
//  Created by 김응철 on 2023/01/14.
//

import Foundation

struct CommunityDTO: Codable {
  
  struct Post: Codable {
    let postId: Int
    let title: String
    let content: String
    let nickname: String
    let commentsCount: Int
    let likesCount: Int
    let imagesCount: Int
    let createdAt: String
  }
}
