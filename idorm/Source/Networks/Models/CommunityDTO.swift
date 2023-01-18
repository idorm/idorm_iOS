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
    let nickname: String
    let commentsCount: Int
    let likesCount: Int
    let imagesCount: Int
    let createdAt: String
  }
  
  struct Save {
    let content: String
    let title: String
    let dormNum: Dormitory
    let assets: [PHAsset]
    let isAnonymous: Bool
  }
}
