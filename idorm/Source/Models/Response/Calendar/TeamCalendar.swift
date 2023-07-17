//
//  TeamCalendars.swift
//  idorm
//
//  Created by 김응철 on 7/11/23.
//

import Foundation

/// 팀의 일정 월별 조회에 필요한 모델입니다.
struct TeamCalendar: Decodable {
  let isSleepover: Bool
  let startDate: Date
  let targets: [TeamMember]
  let teamCalendarId: Int
  let title: String
}
