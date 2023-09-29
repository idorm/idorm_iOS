//
//  CommunityPostListSection.swift
//  idorm
//
//  Created by 김응철 on 9/27/23.
//

import UIKit

enum CommunityPostListSection: Hashable {
  case topPost
  case post
  
  var itemSize: NSCollectionLayoutSize {
    switch self {
    case .topPost:
      return NSCollectionLayoutSize(
        widthDimension: .absolute(138.0),
        heightDimension: .absolute(132.0)
      )
    case .post:
      return NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(139.0)
      )
    }
  }
  
  var item: NSCollectionLayoutItem {
    return NSCollectionLayoutItem(layoutSize: self.itemSize)
  }
  
  var group: NSCollectionLayoutGroup {
    switch self {
    case .topPost:
      return NSCollectionLayoutGroup.horizontal(
        layoutSize: self.itemSize,
        subitems: [self.item]
      )
    case .post:
      return NSCollectionLayoutGroup.vertical(
        layoutSize: self.itemSize,
        subitems: [self.item]
      )
    }
  }
  
  var section: NSCollectionLayoutSection {
    let section = NSCollectionLayoutSection(group: self.group)
    switch self {
    case .topPost:
      section.contentInsets =
      NSDirectionalEdgeInsets(top: 12.0, leading: 24.0, bottom: 12.0, trailing: 24.0)
      section.interGroupSpacing = 8.0
      section.orthogonalScrollingBehavior = .continuous
      section.decorationItems = [
        .background(elementKind: CommunityTopPostsBackgroundView.identifier)
      ]
    case .post:
      section.interGroupSpacing = 6.0
    }
    return section
  }
}

enum CommunityPostListSectionItem: Hashable {
  case topPost(Post)
  case post(Post)
}
