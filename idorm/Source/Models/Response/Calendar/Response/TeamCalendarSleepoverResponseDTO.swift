//
//  TeamCalendarSleepoverResponseDTO.swift
//  idorm
//
//  Created by 김응철 on 8/21/23.
//

import Foundation

/// 외박 일정 조회
struct TeamCalendarSleepoverResponseDTO: Codable {
  let endDate: String
  let startDate: String
  let teamCalendarId: Int
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.endDate = try container.decode(String.self, forKey: .endDate)
      .toDateString(from: "yyyy-MM-dd", to: "M월 d일")
    self.startDate = try container.decode(String.self, forKey: .startDate)
      .toDateString(from: "yyyy-MM-dd", to: "M월 d일")
    self.teamCalendarId = try container.decode(Int.self, forKey: .teamCalendarId)
  }
}
