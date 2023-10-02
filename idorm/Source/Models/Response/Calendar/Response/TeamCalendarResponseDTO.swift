//
//  TeamCalendars.swift
//  idorm
//
//  Created by 김응철 on 7/11/23.
//

import Foundation

/// 공유 캘린더의 월별 조회를 나타내는 간략한 DTO입니다.
struct TeamCalendarResponseDTO: Codable, Hashable {
  let startDate: String
  let endDate: String
  let targets: [TeamCalendarSingleMemberResponseDTO]
  let teamCalendarId: Int
  let title: String
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.startDate = try container.decode(String.self, forKey: .startDate)
      .toDateString(from: "yyyy-MM-dd", to: "M월 d일")
    self.endDate = try container.decode(String.self, forKey: .endDate)
      .toDateString(from: "yyyy-MM-dd", to: "M월 d일")
    self.targets = try container.decode([TeamCalendarSingleMemberResponseDTO].self, forKey: .targets)
    self.teamCalendarId = try container.decode(Int.self, forKey: .teamCalendarId)
    self.title = try container.decode(String.self, forKey: .title)
  }
}
