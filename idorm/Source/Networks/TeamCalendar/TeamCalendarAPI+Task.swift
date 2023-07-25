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
    }
  }
}
