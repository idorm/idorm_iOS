//
//  TeamCalendarAPI+Task.swift
//  idorm
//
//  Created by 김응철 on 7/16/23.
//

import Foundation

import Moya

extension CalendarAPI {
  func getTask() -> Task {
    switch self {
    case .getTeamMembers:
      return .requestPlain
      
    case .postTeamCalendars(let yearMonth):
      return .requestParameters(
        parameters: ["yearMonth": yearMonth],
        encoding: JSONEncoding.default
      )
      
    case .postDormCalendars(let yearMonth):
      return .requestParameters(
        parameters: ["yearMonth": yearMonth],
        encoding: JSONEncoding.default
      )
      
    case .getTeamCalendar(let teamCalendarId):
      return .requestParameters(
        parameters: ["teamCalendarId": teamCalendarId],
        encoding: URLEncoding.queryString
      )
      
    case .putTeamCalendar(let requestModel):
      return .requestJSONEncodable(requestModel)
      
    case .deleteTeamCalendar(let teamCalendarId):
      return .requestParameters(
        parameters: ["teamCalendarId": teamCalendarId],
        encoding: URLEncoding.queryString
      )
      
    case .postTeamCalendar(let requestModel):
      return .requestJSONEncodable(requestModel)
      
    case .deleteTeam:
      return .requestPlain
      
    case .deleteTeamMember(let memberID):
      return .requestParameters(
        parameters: ["memberId": memberID],
        encoding: URLEncoding.queryString
      )
      
    case let .postSleepoverCalendar(startDate, endDate):
      return .requestParameters(
        parameters: [
          "endDate": endDate,
          "startDate": startDate
        ],
        encoding: JSONEncoding.default
      )
    }
  }
}
