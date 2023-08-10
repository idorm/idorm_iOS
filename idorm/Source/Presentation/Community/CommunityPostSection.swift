//
//  CommunityPostSection.swift
//  idorm
//
//  Created by 김응철 on 8/10/23.
//

import UIKit

enum CommunityPostSection: Hashable {
  /// 게시글 작성자 및 내용
  case contents
  /// 게시글 사진들
  case photos
  /// 게시글 좋아요, 댓글, 사진 갯수 및 공감하기 버튼이 포함
  case multiBox
  /// 게시글 댓글들
  case comments
  
  var size: NSCollectionLayoutSize {
    switch self {
    case .contents:
      return .init(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(90.0)
      )
    case .photos:
      return .init(
        widthDimension: .absolute(120.0),
        heightDimension: .absolute(120.0)
      )
    case .multiBox:
      return .init(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(58.0)
      )
    case .comments:
      return .init(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(137.0)
      )
    }
  }
  
  var section: NSCollectionLayoutSection {
    let item = NSCollectionLayoutItem(layoutSize: self.size)
    let group = NSCollectionLayoutGroup.vertical(layoutSize: self.size, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    
    switch self {
    case .contents:
      break
    case .photos:
      break
    case .multiBox:
      break
    case .comments:
      break
    }
    
    return section
  }
}

enum CommunityPostSectionItem: Hashable {
  case content
  case photo
  case multiBox
  case comment
  case emptyComment
}
