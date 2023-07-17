//
//  TeamCalendarAPI.swift
//  idorm
//
//  Created by 김응철 on 7/16/23.
//

import Moya

enum TeamCalendarAPI {
  /// 팀원 전체 조회
  case getTeamMembers
  /// [팀 / 외박] 일정 월별 조회
  case getMonthlySchedule
}
