//
//  TeamCalendar.swift
//  idorm
//
//  Created by 김응철 on 7/31/23.
//

import Foundation

/// [팀 / 외박] 일정 단건 조회에 필요한 모델입니다.
struct TeamCalendarSingleResponseDTO: Codable, Equatable {
  let content: String
  let endDate: String
  let endTime: String
  let startDate: String
  let startTime: String
  let targets: [TeamCalendarSingleMemberResponseDTO]
  let teamCalendarId: Int
  let title: String
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.content = try container.decode(String.self, forKey: .content)
    self.endDate = try container.decode(String.self, forKey: .endDate)
      .toDateString(from: "yyyy-MM-dd", to: "M월 d일")
    self.endTime = try container.decode(String.self, forKey: .endTime)
      .toDateString(from: "HH:mm:ss", to: "a h:mm")
    self.startDate = try container.decode(String.self, forKey: .startDate)
      .toDateString(from: "yyyy-MM-dd", to: "M월 d일")
    self.startTime = try container.decode(String.self, forKey: .startTime)
      .toDateString(from: "HH:mm:ss", to: "a h:mm")
    self.targets = try container.decode([TeamCalendarSingleMemberResponseDTO].self, forKey: .targets)
    self.teamCalendarId = try container.decode(Int.self, forKey: .teamCalendarId)
    self.title = try container.decode(String.self, forKey: .title)
  }
}
