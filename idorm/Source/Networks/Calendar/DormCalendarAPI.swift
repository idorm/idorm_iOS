//
//  CalendarAPI.swift
//  idorm
//
//  Created by 김응철 on 2023/05/03.
//

import Foundation

import Moya

enum DormCalendarAPI {
  case retrieveCalendars(year: String, month: String)
}

extension DormCalendarAPI: TargetType, BaseAPI {
  func getPath() -> String {
    return ""
  }
  
  func getMethod() -> Moya.Method {
    return .post
  }
  
  func getTask() -> Moya.Task {
    return .requestPlain
  }
  
  static let provider = MoyaProvider<DormCalendarAPI>()
  
  var baseURL: URL { return getBaseURL() }
  
  
  var path: String {
    switch self {
    case .retrieveCalendars:
      return "/member/calendars"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .retrieveCalendars:
      return .post
    }
  }
  
  var task: Moya.Task {
    switch self {
    case let .retrieveCalendars(year, month):
      return .requestParameters(parameters: [
        "yearMonth": "\(year)-\(month)"
      ], encoding: JSONEncoding.default)
    }
  }
  
  var headers: [String : String]? {
    return getJsonHeader()
  }
}
