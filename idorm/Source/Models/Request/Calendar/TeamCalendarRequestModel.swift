//
//  TeamCalendarRequestModel.swift
//  idorm
//
//  Created by 김응철 on 7/31/23.
//

import Foundation

/// [일정 / 외박] 에 대해서 생성, 수정할 때 필요한
/// `RequestModel`입니다.
struct TeamCalendarRequestModel: Codable {
  var content: String = ""
  var endDate: String = ""
  var endTime: String = ""
  var startDate: String = ""
  var startTime: String = ""
  var targets: [Int] = []
  var title: String = ""
}
