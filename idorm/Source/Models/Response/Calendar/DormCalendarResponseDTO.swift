//
//  DormCalendar.swift
//  idorm
//
//  Created by 김응철 on 7/24/23.
//

import Foundation

struct DormCalendarResponseDTO: Codable, Hashable {
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
