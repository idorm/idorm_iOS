//
//  Gender.swift
//  idorm
//
//  Created by 김응철 on 9/15/23.
//

import Foundation

enum Gender: String, Codable, CaseIterable {
  case male = "MALE"
  case female = "FEMALE"
  
  /// Ex. 남자
  var description: String {
    switch self {
    case .male: "남성"
    case .female: "여성"
    }
  }
  
  var parsingString: String {
    switch self {
    case .male: "MALE"
    case .female: "FEMALE"
    }
  }
}
