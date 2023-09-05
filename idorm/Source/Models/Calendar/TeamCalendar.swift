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
  /// 일정의 식별자
  var identifier: Int = -1
  var content: String = ""
  var endDate: String = ""
  var endTime: String = ""
  var startDate: String = ""
  var startTime: String = ""
  var targets: [TeamMember] = []
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
    self.endDate = endDate.toString("yyyy-MM-dd")
    self.startDate = Date().toString("yyyy-MM-dd")
  }
  
  /// `TeamCalendarSleepoverResponseDTO`를 변환합니다.
  init(_ responseDTO: TeamCalendarSleepoverResponseDTO) {
    self.identifier = responseDTO.teamCalendarId
    self.startDate = responseDTO.startDate.toDateString(from: "yyyy-MM-dd", to: "M월 d일")
    self.endDate = responseDTO.endDate.toDateString(from: "yyyy-MM-dd", to: "M월 d일")
  }
}

struct TeamMember: Hashable {
  /// 멤버의 식별자
  let identifier: Int
  let nickname: String
  let order: Int
  let profilePhotoURL: String?
}
