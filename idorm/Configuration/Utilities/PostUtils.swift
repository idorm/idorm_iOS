//
//  PostUtils.swift
//  idorm
//
//  Created by 김응철 on 2023/01/11.
//

import UIKit

final class PostUtils {
  
  static func popularPostSection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .absolute(138),
      heightDimension: .absolute(132)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .absolute(404),
      heightDimension: .absolute(132)
    )
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      repeatingSubitem: item,
      count: 3
    )
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 8
    section.contentInsets = NSDirectionalEdgeInsets(
      top: 12, leading: 24, bottom: 12, trailing: 24
    )
    section.orthogonalScrollingBehavior = .continuous
    
    return section
  }
  
  static func postSection() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(136)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(136)
    )
    let group = NSCollectionLayoutGroup.vertical(
      layoutSize: groupSize,
      repeatingSubitem: item,
      count: 1
    )
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 6
    
    return section
  }
}
