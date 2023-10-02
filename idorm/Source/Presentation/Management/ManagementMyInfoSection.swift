//
//  ManagementMyInfoSection.swift
//  idorm
//
//  Created by 김응철 on 9/29/23.
//

import UIKit

enum ManagementMyInfoSection: Hashable {
  case profileImage
  case main
  case service
  case membership
  
  var itemSize: NSCollectionLayoutSize {
    switch self {
    case .profileImage:
      return NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(147.0)
      )
    case .main, .service:
      return NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(24.0)
      )
    case .membership:
      return NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(109.0)
      )
    }
  }
  
  var footerItemSize: NSCollectionLayoutSize {
    return .init(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(78.0)
    )
  }
  
  var item: NSCollectionLayoutItem { .init(layoutSize: self.itemSize) }
  
  var group: NSCollectionLayoutGroup {
    .vertical(layoutSize: self.itemSize, subitems: [self.item])
  }
  
  var section: NSCollectionLayoutSection {
    let section = NSCollectionLayoutSection(group: self.group)
    section.interGroupSpacing = 24.0
    switch self {
    case .main, .service:
      let footer = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: self.footerItemSize,
        elementKind: ManagementMyInfoFooterView.reuseIdentifier,
        alignment: .bottom
      )
      section.boundarySupplementaryItems = [footer]
    case .membership:
      section.contentInsets = .init(top: .zero, leading: 24.0, bottom: 24.0, trailing: 24.0)
    default: break
    }
    return section
  }
}

enum ManagementMyInfoSectionItem: Hashable {
  case profileImage(imageURL: String?)
  case nickname(nickname: String)
  case changePassword
  case email(email: String)
  case terms
  case version
  case membership
  
  var title: String {
    switch self {
    case .nickname: "닉네임"
    case .changePassword: "비밀번호 변경"
    case .email: "이메일"
    case .terms: "서비스 약관 자세히 보기"
    case .version: "버전정보"
    default: ""
    }
  }
  
  var isHiddenRightButton: Bool {
    switch self {
    case .email, .version: true
    default: false
    }
  }
  
  var subtitleTrailingInset: CGFloat {
    switch self {
    case .nickname: 48.0
    case .email, .version: 24.0
    default: 0.0
    }
  }
}
