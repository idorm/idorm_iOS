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
  case teamMembers([TeamCalendarSingleMemberResponseDTO], isEditing: Bool)
  /// 메인 달력이 있는 섹션입니다.
  case calendar(teamCalenars: [TeamCalendarResponseDTO], dormCalendars: [DormCalendarResponseDTO])
  /// 우리 방 일정
  case teamCalendar(isEditing: Bool)
  /// 기숙사 일정
  case dormCalendar
  
  /// 헤더에 들어갈 `String` 값입니다.
  var headerContent: String {
    switch self {
    case .dormCalendar:
      return "기숙사 일정"
    case .teamCalendar:
      return "우리방 일정"
    default:
      return ""
    }
  }
}

/// `Item`을 기준으로 나누어진 섹션입니다.
enum CalendarSectionItem: Hashable {
  case teamMember(TeamCalendarSingleMemberResponseDTO)
  case teamCalendar(TeamCalendarResponseDTO)
  case dormCalendar(DormCalendarResponseDTO)
  case dormEmpty
}
