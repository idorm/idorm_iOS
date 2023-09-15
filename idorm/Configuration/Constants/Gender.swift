//
//  Genders.swift
//  idorm
//
//  Created by 김응철 on 9/15/23.
//

import Foundation

enum Gender: String, Codable {
  case male = "MALE"
  case female = "FEMALE"
  
  var parsingString: String {
    switch self {
    case .male:
      return "MALE"
    case .female:
      return "FEMALE"
    }
  }
  
  var cardString: String {
    switch self {
    case .male: return "남자"
    case .female: return "여자"
    }
  }
}
