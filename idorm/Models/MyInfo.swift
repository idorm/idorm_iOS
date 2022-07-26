//
//  Onboarding.swift
//  idorm
//
//  Created by 김응철 on 2022/07/23.
//

import Foundation

struct MyInfo {
  var dormNumber: Dormitory
  var period: String
  var gender: Bool
  var age: String
  var snoring: Bool
  var grinding: Bool
  var smoke: Bool
  var allowedFood: Bool
  var earphone: Bool
  var wakeupTime: String
  var cleanUpStatus: String
  var showerTime: String
  var mbti: String?
  var wishText: String?
  var chatLink: String?
}

enum Dormitory {
  case no1
  case no2
  case no3
}

enum Join
