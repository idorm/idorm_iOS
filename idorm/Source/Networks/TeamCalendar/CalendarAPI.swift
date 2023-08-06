//
//  TeamCalendarAPI.swift
//  idorm
//
//  Created by 김응철 on 7/16/23.
//

import Foundation

import Moya

enum CalendarAPI {
  /// 팀원 전체 조회
  ///
  /// - 팀에 소속된 팀원이 1명이라면, isNeedToConfirmDeleted: true 로 응답합니다.
  /// - 남은 팀원 1명이 팀 폭발 여부를 확인했다면, 팀 폭발 인지 OK 요청 을 서버에게 보내주세요.
  /// - 팀원이 없다면 팀 식별자(teamId)가 -999 이고, members는 로그인한 회원만 담은 배열로 응답합니다.
  /// - json 내부의 회원 배열에서, 회원의 order는 0부터 시작합니다.
  case getTeamMembers
  
  /// [팀 / 외박] 일정 월별 조회
  ///
  /// 종료일이 지난 일정도 전부 응답합니다.
  ///
  /// - Parameters:
  ///  - yearMonth: Ex. `2023-04`
  case postTeamCalendars(yearMonth: String)
  
  /// 기숙사 공식 일정 월별 조회
  ///
  /// - 모든 기숙사의 일정을 반환합니다.
  /// - 종료된 일정은 제거한 후, 최신 등록 순으로 응답합니다.
  ///
  /// - Parameters:
  ///  - yearMonth: Ex. `2023-04`
  case postDormCalendars(yearMonth: String)
  
  /// [팀 / 외박] 일정 단건 조회
  case getTeamCalendar(teamCalendarId: Int)
}

extension CalendarAPI: TargetType, BaseAPI {
  var baseURL: URL { self.getBaseURL() }
  var path: String { self.getPath() }
  var method: Moya.Method { self.getMethod() }
  var task: Moya.Task { self.getTask() }
  var headers: [String : String]? { self.getJsonHeader() }
}
