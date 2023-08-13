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
  
  var item: NSCollectionLayoutItem {
    return NSCollectionLayoutItem(layoutSize: self.size)
  }
  
  var group: NSCollectionLayoutGroup {
    let group: NSCollectionLayoutGroup
    switch self {
    case .photos:
      group = .horizontal(layoutSize: self.size, subitems: [self.item])
    default:
      group = .vertical(layoutSize: self.size, subitems: [self.item])
    }
    return group
  }
  
  var section: NSCollectionLayoutSection {
    let section = NSCollectionLayoutSection(group: self.group)
    switch self {
    case .contents:
      section.contentInsets = NSDirectionalEdgeInsets(
        top: 16.0,
        leading: 24.0,
        bottom: .zero,
        trailing: 24.0
      )
    case .photos:
      section.contentInsets.top = 24.0
      section.contentInsets.leading = 24.0
      section.orthogonalScrollingBehavior = .continuous
      section.interGroupSpacing = 8.0
    case .multiBox:
      section.contentInsets.top = 24.0
    case .comments:
      section.contentInsets.bottom = 24.0
    }
    return section
  }
}

enum CommunityPostSectionItem: Hashable {
  case content(Post)
  case photo(String?)
  case multiBox(Post)
  case comment(Comment)
  case emptyComment
}
