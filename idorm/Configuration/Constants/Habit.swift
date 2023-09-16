//
//  Habit.swift
//  idorm
//
//  Created by 김응철 on 9/15/23.
//

import Foundation

enum Habit: CaseIterable {
  case snoring
  case grinding
  case smoking
  case allowedFood
  case allowedEarphone
  
  var description: String {
    switch self {
    case .snoring: "코골이"
    case .grinding: "이갈이"
    case .smoking: "흡연"
    case .allowedFood: "실내 음식 섭취 함"
    case .allowedEarphone: "이어폰 착용 안 함"
    }
  }
}
