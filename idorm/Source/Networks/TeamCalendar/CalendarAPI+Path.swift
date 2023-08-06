//
//  TeamCalendarAPI+Path.swift
//  idorm
//
//  Created by 김응철 on 7/16/23.
//

import Foundation

extension CalendarAPI {
  func getPath() -> String {
    switch self {
    case .getTeamMembers:
      return "/api/v1/member/team"
      
    case .postTeamCalendars:
      return "/api/v1/member/team/calendars"
      
    case .postDormCalendars:
      return "/member/calendars"
      
    case .getTeamCalendar:
      return "/api/v1/member/team/calendar"
    }
  }
}
