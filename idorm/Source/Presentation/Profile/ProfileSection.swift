//
//  MyPageSection.swift
//  idorm
//
//  Created by 김응철 on 9/29/23.
//

import UIKit

enum ProfileSection: Hashable {
  case profile
  case roommate
  case publicSetting
  case community
  
  var itemSize: NSCollectionLayoutSize {
    switch self {
    case .profile:
      return NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(190.0)
      )
    case .publicSetting:
      return NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(53.0)
      )
    default :
      return NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0 / 3),
        heightDimension: .absolute(102.0)
      )
    }
  }
  
  var headerItemSize: NSCollectionLayoutSize {
    return NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(56.0)
    )
  }
  
  var decorationItemSize: NSCollectionLayoutSize {
    switch self {
    case .roommate:
      return NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(211.0)
      )
    default:
      return NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(170.0)
      )
    }
  }
  
  var headerTitle: String {
    switch self {
    case .roommate: "룸메이트 매칭 관리"
    case .community: "커뮤니티 관리"
    default: ""
    }
  }
  
  var item: NSCollectionLayoutItem {
    return NSCollectionLayoutItem(layoutSize: self.itemSize)
  }
  
  var group: NSCollectionLayoutGroup {
    switch self {
    case .roommate, .community:
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .absolute(102.0)
        ),
        repeatingSubitem: self.item,
        count: 3
      )
      group.interItemSpacing = .fixed(16.0)
      return group
    default:
      return NSCollectionLayoutGroup.horizontal(
        layoutSize: self.itemSize,
        subitems: [self.item]
      )
    }
  }
  
  var section: NSCollectionLayoutSection {
    let section = NSCollectionLayoutSection(group: self.group)
    section.contentInsets = self.contentInsets
    switch self {
    case .roommate, .community:
      let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: self.headerItemSize,
        elementKind: ProfileHeaderView.reuseIdentifier,
        alignment: .topLeading
      )
      let decorationItem = NSCollectionLayoutDecorationItem.background(
        elementKind: ProfileDecorationView.reuseIdentifier
      )
      decorationItem.contentInsets = self.decorationItemContentInsets
      decorationItem.zIndex = -2
      section.boundarySupplementaryItems = [headerItem]
      section.decorationItems = [decorationItem]
      section.interGroupSpacing = 16.0
    default: break
    }
    return section
  }
  
  var decorationItemContentInsets: NSDirectionalEdgeInsets {
    switch self {
    case .roommate:
      return .init(top: .zero, leading: .zero, bottom: -53.0, trailing: .zero)
    case .community:
      return .init(top: .zero, leading: .zero, bottom: 24.0, trailing: .zero)
    default: return .zero
    }
  }
  
  var contentInsets: NSDirectionalEdgeInsets {
    switch self {
    case .profile:
      return NSDirectionalEdgeInsets(top: .zero, leading: .zero, bottom: 24.0, trailing: .zero)
    case .roommate:
      return NSDirectionalEdgeInsets(top: .zero, leading: 48.0, bottom: .zero, trailing: 48.0)
    case .community:
      return NSDirectionalEdgeInsets(top: .zero, leading: 48.0, bottom: 48.0, trailing: 48.0)
    case .publicSetting:
      return NSDirectionalEdgeInsets(top: .zero, leading: 24.0, bottom: 24.0, trailing: 24.0)
    }
  }
}

enum ProfileSectionItem: Hashable {
  case profile(imageURL: String, nickname: String)
  case matchingImage
  case dislikedRoommate
  case likedRoommate
  case myPost
  case myComment
  case recommendedPost
  case publicSetting(isPublic: Bool)
  
  var image: UIImage? {
    switch self {
    case .profile: 
      return .iDormImage(.human)
    case .matchingImage:
      return .iDormImage(.photo_circle)
    case .dislikedRoommate:
      return .iDormImage(.dislike_circle)
    case .likedRoommate:
      return .iDormImage(.like_circle)
    case .myPost:
      return .iDormImage(.pencil_circle)
    case .myComment:
      return .iDormImage(.speechbubble_circle)
    case .recommendedPost:
      return .iDormImage(.thumb_circle)
    default: return nil
    }
  }
  
  var title: String {
    switch self {
    case .matchingImage: "매칭 이미지"
    case .dislikedRoommate: "싫어요한 룸메"
    case .likedRoommate: "좋아요한 룸메"
    case .myPost: "내가 쓴 글"
    case .myComment: "내가 쓴 댓글"
    case .recommendedPost: "추천한 글"
    default: ""
    }
  }
}
