//
//  CalendarResponseModel.swift
//  idorm
//
//  Created by 김응철 on 2023/05/03.
//

import Foundation

enum CalendarResponseModel {
  struct Calendar: Codable, Hashable {
    let calendarId: Int
    let isDorm1Yn: Bool
    let isDorm2Yn: Bool
    let isDorm3Yn: Bool
    let startDate: String?
    let endDate: String?
    let startTime: String?
    let endTime: String?
    let content: String?
    let location: String?
    let url: String?
  }
}
