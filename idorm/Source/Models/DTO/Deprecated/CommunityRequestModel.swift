//
//  CommunityRequestModel.swift
//  idorm
//
//  Created by 김응철 on 2023/01/27.
//

import UIKit
import Photos

enum CommunityRequestModel {}

extension CommunityRequestModel {
  struct Comment: Codable {
    let content: String
    let isAnonymous: Bool
    let parentCommentId: Int?
  }
  
  struct Post {
    let content: String
    let title: String
    let dormCategory: Dormitory
    let images: [UIImage]
    let isAnonymous: Bool
  }
}
