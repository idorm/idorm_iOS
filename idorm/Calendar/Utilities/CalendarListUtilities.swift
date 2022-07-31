//
//  CalendarUtilities.swift
//  idorm
//
//  Created by 김응철 on 2022/07/27.
//

import Foundation

enum CalendarListType: Int, CaseIterable {
  case chip
  case personal
  case dorm
  
  var listIndex: Int {
    switch self {
    case .chip:
      return 0
    case .personal:
      return 1
    case .dorm:
      return 2
    }
  }
}
