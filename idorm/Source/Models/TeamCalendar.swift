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
  let endDate: String
  let endTime: String
  let startDate: String
  let startTime: String
  let targets: [TeamMember]
  let title: String
}

struct TeamMember: Hashable {
  /// 멤버의 식별자
  let identifier: Int
  let nickname: String
  let order: Int
  let profilePhotoURL: String?
}
