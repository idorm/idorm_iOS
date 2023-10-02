//
//  JoinPeriod.swift
//  idorm
//
//  Created by 김응철 on 9/15/23.
//

import Foundation

enum JoinPeriod: String, Codable, CaseIterable {
  case period_16 = "WEEK16"
  case period_24 = "WEEK24"
  
  var description: String {
    switch self {
    case .period_16: "짧은 기간"
    case .period_24: "긴 기간"
    }
  }
  
  var parsingString: String {
    switch self {
    case .period_16: "WEEK16"
    case .period_24: "WEEK24"
    }
  }
}
