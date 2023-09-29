//
//  ManagementSection.swift
//  idorm
//
//  Created by 김응철 on 9/29/23.
//

import UIKit

enum ManagementSection: Hashable {
  case post
  case comment
  case matchingCard
  
  var itemSize: NSCollectionLayoutSize {
    switch self {
    case .post:
      return NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(139.0)
      )
    case .comment:
      return NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(137.0)
      )
    case .matchingCard:
      return NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(484.0)
      )
    }
  }
  
  var item: NSCollectionLayoutItem {
    return NSCollectionLayoutItem(layoutSize: self.itemSize)
  }
  
  var group: NSCollectionLayoutGroup {
    return NSCollectionLayoutGroup.vertical(layoutSize: self.itemSize, subitems: [self.item])
  }
  
  var section: NSCollectionLayoutSection {
    let section = NSCollectionLayoutSection(group: self.group)
    switch self {
    case .post:
      section.interGroupSpacing = 6.0
    case .comment:
      section.interGroupSpacing = 1.0
    case .matchingCard:
      section.interGroupSpacing = 10.0
    }
    return section
  }
}

enum ManagementSectionItem: Hashable {
  case post(Post)
  case comment(Comment)
  case matchingCard(MatchingInfo)
}
