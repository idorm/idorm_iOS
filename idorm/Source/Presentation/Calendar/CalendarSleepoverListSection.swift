//
//  CalendarSleepoverListSection.swift
//  idorm
//
//  Created by 김응철 on 8/21/23.
//

import UIKit

enum CalendarSleepoverListSection: Hashable {
  case sleepover(canEdit: Bool)
  
  var size: NSCollectionLayoutSize {
    return .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40.0))
  }
  
  var item: NSCollectionLayoutItem {
    return .init(layoutSize: self.size)
  }
  
  var group: NSCollectionLayoutGroup {
    return .vertical(layoutSize: self.size, subitems: [self.item])
  }
  
  var section: NSCollectionLayoutSection {
    let section = NSCollectionLayoutSection(group: self.group)
    let headerSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(48.0)
    )
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: headerSize,
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top
    )
    section.contentInsets = NSDirectionalEdgeInsets(
      top: 12.0,
      leading: 24.0,
      bottom: 18.0,
      trailing: 24.0
    )
    section.boundarySupplementaryItems = [header]
    return section
  }
}

enum CalendarSleepoverListSectionItem: Hashable {
  case sleepover(calendar: TeamCalendar, isEditing: Bool, isMyOwnCalendar: Bool)
}
