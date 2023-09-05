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
      return "/member/team"
      
    case .postTeamCalendars:
      return "/member/team/calendars"
      
    case .postDormCalendars:
      return "/member/calendars"
      
    case .getTeamCalendar:
      return "/member/team/calendar"
      
    case .putTeamCalendar:
      return "/member/team/calendar"
      
    case .deleteTeamCalendar:
      return "/member/team/calendar"
      
    case .postTeamCalendar:
      return "/member/team/calendar"
      
    case .deleteTeam:
      return "/member/team"
      
    case .deleteTeamMember:
      return "/member/team"
      
    case .postSleepoverCalendar:
      return "/member/team/calendar/sleepover"
      
    case .postSleepoverCalendars:
      return "/member/team/calendars/sleepover"
      
    case .postAcceptInvitation:
      return "/member/team"
    }
  }
}
