//
//  TeamCalendarAPI+Method.swift
//  idorm
//
//  Created by 김응철 on 7/16/23.
//

import Foundation

import Moya

extension CalendarAPI {
  func getMethod() -> Moya.Method {
    switch self {
    case .getTeamMembers:
      return .get
    case .getTeamCalendars:
      return .post
    case .getDormCalendars:
      return .post
    case .getTeamCalendar:
      return .get
    case .updateTeamCalendar:
      return .put
    case .deleteTeamCalendar:
      return .delete
    case .createTeamCalendar:
      return .post
    case .deleteTeam:
      return .delete
    case .deleteTeamMember:
      return .delete
    case .createSleepoverCalendar:
      return .post
    case .getSleepoverCalendars:
      return .post
    case .postAcceptInvitation:
      return .post
    }
  }
}
