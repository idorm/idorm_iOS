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
      
    case .postTeamCalendars:
      return .post
      
    case .postDormCalendars:
      return .post
    }
  }
}
