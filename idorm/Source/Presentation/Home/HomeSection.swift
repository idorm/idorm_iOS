//
//  HomeSection.swift
//  idorm
//
//  Created by 김응철 on 8/19/23.
//

import UIKit

enum HomeSection: Hashable {
  case main
  case topPosts
  case dormCalendars
  
  var size: NSCollectionLayoutSize {
    switch self {
    case .main:
      return .init(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(300.0)
      )
      
    case .topPosts:
      return .init(
        widthDimension: .absolute(138.0),
        heightDimension: .absolute(132.0)
      )
      
    case .dormCalendars:
      return .init(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(200.0)
      )
    }
  }
  
  var item: NSCollectionLayoutItem {
    return NSCollectionLayoutItem(layoutSize: self.size)
  }
  
  var group: NSCollectionLayoutGroup {
    let group: NSCollectionLayoutGroup
    switch self {
    case .topPosts:
      group = .horizontal(layoutSize: self.size, subitems: [self.item])
    case .main, .dormCalendars:
      group = .vertical(layoutSize: self.size, subitems: [self.item])
    }
    return group
  }
  
  var section: NSCollectionLayoutSection {
    let section = NSCollectionLayoutSection(group: self.group)
    switch self {
    case .main:
      section.contentInsets = NSDirectionalEdgeInsets(
        top: 24.0,
        leading: 24.0,
        bottom: .zero,
        trailing: 24.0
      )
    case .topPosts:
      section.contentInsets = NSDirectionalEdgeInsets(
        top: 12.0,
        leading: 24.0,
        bottom: 12.0,
        trailing: 24.0
      )
      section.interGroupSpacing = 8.0
      section.orthogonalScrollingBehavior = .continuous
      section.decorationItems = [
        .background(elementKind: CommunityTopPostsBackgroundView.identifier)
      ]
    case .dormCalendars:
      section.contentInsets = NSDirectionalEdgeInsets(
        top: .zero,
        leading: 24.0,
        bottom: 24.0,
        trailing: 24.0
      )
      // Header
      let headerSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(108.0)
      )
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: headerSize,
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      section.boundarySupplementaryItems = [header]
    }
    return section
  }
}

enum HomeSectionItem: Hashable {
  case main
  case topPost(Post)
  case dormCalendar(DormCalendar)
  case emptyDormCalendar
}
