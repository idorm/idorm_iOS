//
//  CommunityPostingSection.swift
//  idorm
//
//  Created by 김응철 on 9/28/23.
//

import UIKit

enum CommunityPostingSection: Hashable {
  case title
  case images
  case content
  
  var itemSize: NSCollectionLayoutSize {
    switch self {
    case .title:
      return NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(50.0)
      )
    case .images:
      return NSCollectionLayoutSize(
        widthDimension: .absolute(86.0),
        heightDimension: .absolute(86.0)
      )
    case .content:
      return NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalHeight(0.7)
      )
    }
  }
  
  var item: NSCollectionLayoutItem {
    return NSCollectionLayoutItem(layoutSize: self.itemSize)
  }
  
  var group: NSCollectionLayoutGroup {
    switch self {
    case .title, .content:
      return NSCollectionLayoutGroup.vertical(layoutSize: self.itemSize, subitems: [self.item])
    case .images:
      return NSCollectionLayoutGroup.horizontal(layoutSize: self.itemSize, subitems: [self.item])
    }
  }
  
  var section: NSCollectionLayoutSection {
    let section = NSCollectionLayoutSection(group: self.group)
    switch self {
    case .content:
      section.contentInsets =
      NSDirectionalEdgeInsets(top: 0.0, leading: 20.0, bottom: 20.0, trailing: 20.0)
    case .title:
      section.contentInsets =
      NSDirectionalEdgeInsets(top: 0.0, leading: 24.0, bottom: 24.0, trailing: 16.0)
    default:
      section.interGroupSpacing = 8.0
      section.orthogonalScrollingBehavior = .continuous
      section.contentInsets =
      NSDirectionalEdgeInsets(top: 0.0, leading: 24.0, bottom: 24.0, trailing: 24.0)
    }
    return section
  }
}

enum CommunityPostingSectionItem: Hashable {
  case title
  case image(UIImage?)
  case content
}
