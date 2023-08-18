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
  
  /**
   기숙사 공식 일정 월별 조회
   
   모든 기숙사의 일정을 반환합니다.
   
   종료된 일정은 제거한 후, 최신 등록 순으로 응답합니다.
   
   - Parameters:
     - yearMonth: Ex. `2023-04`
   */
  case postDormCalendars(yearMonth: String)
  
  /// [팀 / 외박] 일정 단건 조회
  case getTeamCalendar(teamCalendarId: Int)
  
  /**
   [팀] 일정 수정
   
   - targets 필드는 회원 식별자 배열을 주세요
  */
  case putTeamCalendar(TeamCalendarRequestModel)
  
  /**
   [팀/외박] 일정 삭제
   
   - 팀일정은 팀에 소속된 회원이라면 누구나 삭제 가능합니다.
   - 외박 일정은 본인의 것만 삭제 가능합니다.
  */
  case deleteTeamCalendar(teamCalendarId: Int)
  
  /**
   [팀] 일정 생성
   
   - targets 필드는 회원 식별자 배열을 주세요,
   */
  case postTeamCalendar(TeamCalendarRequestModel)
  
  /**
   팀 나가기
   */
  case deleteTeam
  
  /**
   팀원 삭제
   
   - 본인 혹은 팀의 다른 회원을 팀에서 삭제시킬 때 사용합니다.
   - 로그인한 유저가 팀이 없는 경우는 404(TEAM_NOT_FOUND) 를 응답합니다.
   - 다른 팀원을 삭제하려는 경우, 삭제하려는 팀원의 팀이 없거나 같은 팀이 아닐 경우 403(ACCESS_DENIED_TEAM) 을 응답합니다.
   */
  case deleteTeamMember(memberID: Int)
  
  /**
   [외박] 일정 생성

   - 외박일정은 본인의 것만 생성 가능합니다.
   */
  case postSleepoverCalendar(startDate: String, endDate: String)
  }

extension CalendarAPI: TargetType, BaseAPI {
  var baseURL: URL { self.getBaseURL() }
  var path: String { self.getPath() }
  var method: Moya.Method { self.getMethod() }
  var task: Moya.Task { self.getTask() }
  var headers: [String : String]? { self.getJsonHeader() }
}
