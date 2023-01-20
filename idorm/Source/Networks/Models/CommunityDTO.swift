//
//  CommunityDTO.swift
//  idorm
//
//  Created by 김응철 on 2023/01/14.
//

import UIKit
import Photos

struct CommunityDTO: Codable {
  
  struct Post: Codable, Equatable {
    let postId: Int
    let title: String
    let content: String
    let nickname: String?
    let commentsCount: Int
    let likesCount: Int
    let imagesCount: Int
    let createdAt: String
    
    init(from decoder: Decoder) throws {
      let container: KeyedDecodingContainer<CommunityDTO.Post.CodingKeys> = try decoder.container(keyedBy: CommunityDTO.Post.CodingKeys.self)
      self.postId = try container.decode(Int.self, forKey: CommunityDTO.Post.CodingKeys.postId)
      self.title = try container.decode(String.self, forKey: CommunityDTO.Post.CodingKeys.title)
      self.content = try container.decode(String.self, forKey: CommunityDTO.Post.CodingKeys.content)
      self.commentsCount = try container.decode(Int.self, forKey: CommunityDTO.Post.CodingKeys.commentsCount)
      self.likesCount = try container.decode(Int.self, forKey: CommunityDTO.Post.CodingKeys.likesCount)
      self.imagesCount = try container.decode(Int.self, forKey: CommunityDTO.Post.CodingKeys.imagesCount)
      self.createdAt = try container.decode(String.self, forKey: CommunityDTO.Post.CodingKeys.createdAt)
      
      var nickname = try container.decode(String?.self, forKey: CommunityDTO.Post.CodingKeys.nickname)
            
      switch nickname {
      case "anonymous":
        nickname = "익명"
      case nil:
        nickname = "탈퇴 사용자"
      default:
        break
      }
      
      self.nickname = nickname
    }
  }
  
  struct Save {
    let content: String
    let title: String
    let dormNum: Dormitory
    let assets: [PHAsset]
    let isAnonymous: Bool
  }
}
