//
//  TeamCalendarRequestModel.swift
//  idorm
//
//  Created by 김응철 on 7/31/23.
//

import Foundation

/// [일정 / 외박] 에 대해서 생성, 수정할 때 필요한 `RequestModel`입니다.
struct TeamCalendarRequestDTO: Codable {
  var content: String
  var endDate: String
  var endTime: String
  var startDate: String
  var startTime: String
  var targets: [Int]
  var title: String
  var teamCalendarId: Int?
  
  init(_ teamCalendar: TeamCalendar) {
    self.content = teamCalendar.content
    self.endDate = teamCalendar.endDate.toDateString(from: "M월 d일", to: "yyyy-MM-dd")
    self.endTime = teamCalendar.endTime.toDateString(from: "a h:mm", to: "HH:mm:ss")
    self.startDate = teamCalendar.startDate.toDateString(from: "M월 d일", to: "yyyy-MM-dd")
    self.startTime = teamCalendar.startTime.toDateString(from: "a h:mm", to: "HH:mm:ss")
    self.targets = teamCalendar.members.map { $0.identifier }
    self.title = teamCalendar.title
    self.teamCalendarId = teamCalendar.identifier
  }
}
