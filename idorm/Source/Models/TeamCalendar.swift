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
  let identifier: Int
  let content: String
  var endDate: String
  let endTime: String
  var startDate: String
  let startTime: String
  let targets: [TeamMember]
  let title: String
  
  /// 빈 `TeamCalendar`를 얻기 위한 이니셜라이저
  ///
  /// - Note: 절대로 그냥 사용해서는 안 됩니다!
  init() {
    var dateComponents = DateComponents()
    dateComponents.day = 1
    guard
      let endDate = Calendar.current.date(byAdding: dateComponents, to: Date())
    else { fatalError("날짜 변환에 실패했습니다!") }
    self.identifier = -1
    self.content = ""
    self.endDate = endDate.toString("yyyy-MM-dd")
    self.endTime = ""
    self.startDate = Date().toString("yyyy-MM-dd")
    self.startTime = ""
    self.targets = []
    self.title = ""
  }
}

struct TeamMember: Hashable {
  /// 멤버의 식별자
  let identifier: Int
  let nickname: String
  let order: Int
  let profilePhotoURL: String?
}
