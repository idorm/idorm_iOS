//
//  TeamCalendar.swift
//  idorm
//
//  Created by 김응철 on 8/15/23.
//

import Foundation

/// `CommunityAPI`에서 응답으로 받은 데이터를
/// 로컬에서 사용할 `TeamCalendar`로 변환하여 사용할 구조체입니다.
struct TeamCalendar: Hashable {
  static let dateFormat = "M월 d일"
  static let timeFormat = "a h:mm"
  
  /// 일정의 식별자
  var identifier: Int = -1
  var content: String = ""
  var endDate: String = ""
  var endTime: String = ""
  var startDate: String = ""
  var startTime: String = ""
  var members: [TeamMember] = []
  var title: String = ""
  
  /// 빈 `TeamCalendar`를 얻기 위한 이니셜라이저
  ///
  /// - Note: 절대로 그냥 사용해서는 안 됩니다!
  init() {
    var dateComponents = DateComponents()
    dateComponents.day = 1
    guard
      let endDate = Calendar.current.date(byAdding: dateComponents, to: Date())
    else { fatalError("날짜 변환에 실패했습니다!") }
    self.endDate = endDate.toString(TeamCalendar.dateFormat)
    self.startDate = Date().toString(TeamCalendar.dateFormat)
    self.startTime = Date().toString(TeamCalendar.timeFormat)
    self.endDate = Date().addingTimeInterval(3600).toString(TeamCalendar.timeFormat)
  }
  
  init(_ responseDTO: TeamCalendarSleepoverResponseDTO) {
    self.identifier = responseDTO.teamCalendarId
    self.startDate = responseDTO.startDate
    self.endDate = responseDTO.endDate
  }
  
  init(_ responseDTO: TeamCalendarResponseDTO) {
    self.identifier = responseDTO.teamCalendarId
    self.startDate = responseDTO.startDate
    self.endDate = responseDTO.endDate
    self.members = responseDTO.targets.map { TeamMember($0) }
    self.title = responseDTO.title
  }
  
  init(_ responseDTO: TeamCalendarSingleResponseDTO) {
    self.identifier = responseDTO.teamCalendarId
    self.content = responseDTO.content
    self.endDate = responseDTO.endDate
    self.endTime = responseDTO.endTime
    self.startDate = responseDTO.startDate
    self.startTime = responseDTO.startTime
    self.members = responseDTO.targets.map { TeamMember($0) }
    self.title = responseDTO.title
  }
}

