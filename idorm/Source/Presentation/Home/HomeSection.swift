//
//  HomeSection.swift
//  idorm
//
//  Created by 김응철 on 2023/05/25.
//

import UIKit

enum HomeSection {
  case popularPost
  case calendar
}

enum HomeSectionItem: Hashable {
  case post(CommunityResponseModel.Posts)
  case calendar(CalendarResponseModel.Calendar)
}

extension HomeSection {
  var section: NSCollectionLayoutSection {
    switch self {
    case .popularPost:
      let itemSize = NSCollectionLayoutSize(
        widthDimension: .absolute(138.0),
        heightDimension: .absolute(132.0)
      )
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
      let groupSize = NSCollectionLayoutSize(
        widthDimension: .absolute(138.0),
        heightDimension: .absolute(132.0)
      )
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: groupSize,
        repeatingSubitem: item,
        count: 1
      )
      
      let section = NSCollectionLayoutSection(group: group)
      section.interGroupSpacing = 8.0
      return section
    case .calendar:
      let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(100.0)
      )
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
      let groupSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(100.0)
      )
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: groupSize,
        repeatingSubitem: item,
        count: 1
      )
      
      let section = NSCollectionLayoutSection(group: group)
      return section
    }
  }
}
