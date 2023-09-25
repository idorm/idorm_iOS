//
//  OnboardingSection.swift
//  idorm
//
//  Created by 김응철 on 9/14/23.
//

import UIKit

// MARK: - Section

enum MatchingInfoSetupSection: Hashable {
  case dormitory
  case gender
  case period
  case habit(isFilterSetupVC: Bool)
  case age(isFilterSetupVC: Bool)
  case wakeUpTime
  case arrangement
  case showerTime
  case kakao
  case mbti
  case wantToSay
  
  var title: String? {
    switch self {
    case .dormitory: "기숙사"
    case .gender: "성별"
    case .period: "입사 기간"
    case .habit(let isFilterSetupVC): isFilterSetupVC ? "불호 요소" : "내 습관"
    case .age: "나이"
    default: nil
    }
  }
  
  var subTitle: String? {
    switch self {
    case .habit: "선택하신 요소를 가진 룸메는 나와 매칭되지 않아요."
    case .age: "선택하신 연령대의 룸메이트만 나와 매칭돼요."
    case .wakeUpTime: "기상시간을 알려주세요."
    case .arrangement: "정리정돈을 얼마나 하시나요?"
    case .showerTime: "샤워는 주로 언제/몇 분 동안 하시나요?"
    case .kakao: "연락을 위한 개인 오픈채팅 링크를 알려주세요."
    case .mbti: "MBTI를 알려주세요."
    case .wantToSay: "미래의 룸메에게 하고 싶은 말은?"
    default: nil
    }
  }
  
  var headerHeight: CGFloat {
    switch self {
    case .dormitory: 84.0
    case .gender, .period, .age: 50.0
    case .habit: 72.0
    default: 45.0
    }
  }
  
  var itemSize: NSCollectionLayoutSize {
    switch self {
    case .dormitory, .gender, .period, .habit, .age:
      return NSCollectionLayoutSize(
        widthDimension: .estimated(10.0),
        heightDimension: .absolute(33.0)
      )
    case .wantToSay:
      return NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(148.0)
      )
    default:
      return NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(71.0)
      )
    }
  }
  
  var headerSize: NSCollectionLayoutSize {
    return NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(45.0)
    )
  }
  
  var footerSize: NSCollectionLayoutSize {
    return NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(16.0)
    )
  }
  
  var item: NSCollectionLayoutItem {
    return NSCollectionLayoutItem(layoutSize: self.itemSize)
  }
  
  var group: NSCollectionLayoutGroup {
    switch self {
    case .habit:
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: self.itemSize,
        repeatingSubitem: self.item,
        count: 3
      )
      group.interItemSpacing = .fixed(12.0)
      return group
    default:
      return NSCollectionLayoutGroup.horizontal(
        layoutSize: self.itemSize,
        subitems: [self.item]
      )
    }
  }
  
  var section: NSCollectionLayoutSection {
    let header = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: self.headerSize,
      elementKind: MatchingInfoSetupHeaderView.identifier,
      alignment: .top
    )
    let footer = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: self.footerSize,
      elementKind: MatchingInfoSetupFooterView.identifier,
      alignment: .bottom
    )
    let section = NSCollectionLayoutSection(group: self.group)
    switch self {
    case .dormitory, .gender, .period, .age:
      section.boundarySupplementaryItems = [header, footer]
      section.orthogonalScrollingBehavior = .continuous
      section.interGroupSpacing = 12.0
    case .habit:
      section.boundarySupplementaryItems = [header, footer]
      section.interGroupSpacing = 12.0
    default:
      section.boundarySupplementaryItems = [header]
    }
    section.contentInsets =
    NSDirectionalEdgeInsets(top: .zero, leading: 24.0, bottom: .zero, trailing: 24.0)
    return section
  }
}

// MARK: - Item

enum MatchingInfoSetupSectionItem: Hashable {
  case dormitory(Dormitory, isSelected: Bool)
  case gender(Gender, isSelected: Bool)
  case period(JoinPeriod, isSelected: Bool)
  case habit(Habit, isSelected: Bool)
  case age
  case wakeUpTime
  case arrangement
  case showerTime
  case kakao
  case mbti
  case wantToSay
}
