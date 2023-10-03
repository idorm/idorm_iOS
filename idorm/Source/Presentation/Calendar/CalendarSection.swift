//
//  CalendarSection.swift
//  idorm
//
//  Created by 김응철 on 7/8/23.
//

import UIKit

/// `Header`를 기준으로 나누어진 섹션입니다.
enum CalendarSection: Hashable {
  /// 팀 멤버들의 사진과 닉네임이 들어있는 섹션입니다.
  case teamMembers([TeamMember], isEditing: Bool)
  /// 메인 달력이 있는 섹션입니다.
  case calendar(teamCalenars: [TeamCalendar], dormCalendars: [DormCalendar])
  /// 우리 방 일정
  case teamCalendar
  /// 기숙사 일정
  case dormCalendar
  
  var size: NSCollectionLayoutSize {
    switch self {
    case .teamMembers:
      return .init(widthDimension: .absolute(48.0), heightDimension: .absolute(80.0))
    case .calendar:
      return .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(1.0))
    case .teamCalendar:
      return .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(51.0))
    case .dormCalendar:
      return .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200.0))
    }
  }
  
  var item: NSCollectionLayoutItem { return .init(layoutSize: self.size) }
  
  var group: NSCollectionLayoutGroup {
    let group: NSCollectionLayoutGroup
    switch self {
    case .teamMembers:
      group = .horizontal(layoutSize: self.size, subitems: [self.item])
    default:
      group = .vertical(layoutSize: self.size, subitems: [self.item])
    }
    return group
  }
  
  var section: NSCollectionLayoutSection {
    let section: NSCollectionLayoutSection
    switch self {
    case .teamMembers:
      let headerSize = NSCollectionLayoutSize(
        widthDimension: .absolute(100.0),
        heightDimension: .absolute(112.0)
      )
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: headerSize,
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .trailing
      )
      section = NSCollectionLayoutSection(group: self.group)
      section.boundarySupplementaryItems = [header]
      section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
      section.interGroupSpacing = 20.0
      section.contentInsets = NSDirectionalEdgeInsets(
        top: 18,
        leading: 24,
        bottom: 14,
        trailing: 14
      )
      section.decorationItems = [
        .background(elementKind: CalendarMemberBackgroundView.identifier)
      ]
      
    case .calendar:
      let headerSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(290)
      )
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: headerSize,
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      section = NSCollectionLayoutSection(group: self.group)
      section.boundarySupplementaryItems = [header]
      
    case .teamCalendar:
      let headerSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(45.0)
      )
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: headerSize,
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      section = NSCollectionLayoutSection(group: self.group)
      section.boundarySupplementaryItems = [header]
      section.interGroupSpacing = 18.0
      section.contentInsets = NSDirectionalEdgeInsets(
        top: 18.0,
        leading: 24.0,
        bottom: 18.0,
        trailing: 24.0
      )
      section.decorationItems = [
        .background(elementKind: TeamCalendarBackgroundView.identifier)
      ]
      
    case .dormCalendar:
      let headerSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(45.0)
      )
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: headerSize,
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      section = NSCollectionLayoutSection(group: self.group)
      section.boundarySupplementaryItems = [header]
      section.contentInsets = NSDirectionalEdgeInsets(
        top: 0,
        leading: 24,
        bottom: 44 + 48,
        trailing: 24
      )
    }
    return section
  }
  
  /// 헤더에 들어갈 `ViewType` 값입니다.
  var headerContent: CalendarScheduleHeader.ViewType {
    switch self {
    case .dormCalendar:
      return .dormCalendar
    case .teamCalendar:
      return .teamCalendar
    default:
      return .dormCalendar
    }
  }
}

/// `Item`을 기준으로 나누어진 섹션입니다.
enum CalendarSectionItem: Hashable {
  case teamMember(TeamMember, isEditing: Bool)
  case teamCalendar(TeamCalendar, isEditing: Bool)
  case dormCalendar(DormCalendar)
  case dormEmpty
}
