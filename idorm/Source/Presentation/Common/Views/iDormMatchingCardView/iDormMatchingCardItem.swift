//
//  iDormMatchingCardItem.swift
//  idorm
//
//  Created by 김응철 on 9/18/23.
//

import UIKit

enum iDormMatchingCardItem {
  case snoring(Bool)
  case grinding(Bool)
  case smoking(Bool)
  case allowedFood(Bool)
  case allowedEarphones(Bool)
  case wakeUpTime(String)
  case arrangement(String)
  case showerTime(String)
  case mbti(String)
  
  var title: String {
    switch self {
    case .snoring: "코골이"
    case .grinding: "이갈이"
    case .smoking: "흡연"
    case .allowedFood: "실내 음식"
    case .allowedEarphones: "이어폰 착용"
    case .wakeUpTime: "기상시간"
    case .arrangement: "정리정돈"
    case .showerTime: "샤워시간"
    case .mbti: "MBTI"
    }
  }
  
  var titleFont: UIFont {
    switch self {
    case .snoring, .grinding, .smoking, .allowedFood, .allowedEarphones:
      return .iDormFont(.medium, size: 14.0)
    default:
      return .iDormFont(.bold, size: 14.0)
    }
  }
  
  var subtitleFont: UIFont {
    switch self {
    case .snoring, .grinding, .smoking, .allowedFood, .allowedEarphones:
      return .iDormFont(.bold, size: 14.0)
    default:
      return .iDormFont(.medium, size: 14.0)
    }
  }

  var subtitleString: String {
    switch self {
    case .snoring(let bool):
      return bool ? "있음" : "없음"
    case .grinding(let bool):
      return bool ? "있음" : "없음"
    case .smoking(let bool):
      return bool ? "함" : "안 함"
    case .allowedFood(let bool):
      return bool ? "섭취 함" : "섭취 안 함"
    case .allowedEarphones(let bool):
      return bool ? "함" : "안 함"
    case .wakeUpTime(let string), 
         .arrangement(let string),
         .showerTime(let string),
         .mbti(let string):
      return string
    }
  }
  
  var subtitleColor: UIColor {
    switch self {
    case .snoring(let bool):
      return bool ? .iDormColor(.iDormRed) : .iDormColor(.iDormBlue)
    case .grinding(let bool):
      return bool ? .iDormColor(.iDormRed) : .iDormColor(.iDormBlue)
    case .smoking(let bool):
      return bool ? .iDormColor(.iDormRed) : .iDormColor(.iDormBlue)
    case .allowedFood(let bool):
      return bool ? .iDormColor(.iDormRed) : .iDormColor(.iDormBlue)
    case .allowedEarphones(let bool):
      return bool ? .iDormColor(.iDormBlue) : .iDormColor(.iDormRed)
    default:
      return .iDormColor(.iDormGray400)
    }
  }
}
