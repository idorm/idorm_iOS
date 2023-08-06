//
//  TeamCalendar.swift
//  idorm
//
//  Created by 김응철 on 7/31/23.
//

import Foundation

/// [팀 / 외박] 일정 단건 조회에 필요한 모델입니다.
struct TeamCalendar: Codable, Equatable {
  let content: String
  let endDate: String
  let endTime: String
  let isSleepover: Bool
  let startDate: String
  let startTime: String
  let targets: [TeamMember]
  let teamCalendarId: Int
  let title: String
}
