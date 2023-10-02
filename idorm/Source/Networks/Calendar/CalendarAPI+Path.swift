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
      
    case .getTeamCalendars:
      return "/member/team/calendars"
      
    case .getDormCalendars:
      return "/member/calendars"
      
    case .getTeamCalendar:
      return "/member/team/calendar"
      
    case .updateTeamCalendar:
      return "/member/team/calendar"
      
    case .deleteTeamCalendar:
      return "/member/team/calendar"
      
    case .createTeamCalendar:
      return "/member/team/calendar"
      
    case .deleteTeam:
      return "/member/team"
      
    case .deleteTeamMember:
      return "/member/team"
      
    case .createSleepoverCalendar:
      return "/member/team/calendar/sleepover"
      
    case .getSleepoverCalendars:
      return "/member/team/calendars/sleepover"
      
    case .postAcceptInvitation:
      return "/member/team"
    }
  }
}
