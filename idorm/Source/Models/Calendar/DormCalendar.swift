//
//  DormCalendar.swift
//  idorm
//
//  Created by 김응철 on 8/19/23.
//

import Foundation

struct DormCalendar: Hashable {
  /// 해당 기숙사 공식 일정의 고유 식별자
  let identifier: Int
  let isDorm1Yn: Bool
  let isDorm2Yn: Bool
  let isDorm3Yn: Bool
  var startDate: String? = nil
  var startTime: String? = nil
  var endDate: String? = nil
  var endTime: String? = nil
  let content: String?
  let location: String?
  let url: String?
  
  init(_ responseDTO: DormCalendarResponseDTO) {
    self.identifier = responseDTO.calendarId
    self.isDorm1Yn = responseDTO.isDorm1Yn
    self.isDorm2Yn = responseDTO.isDorm2Yn
    self.isDorm3Yn = responseDTO.isDorm3Yn
    if let startDate = responseDTO.startDate {
      self.startDate = startDate.toDateString(from: "yyyy-MM-dd", to: "M월 d일")
    }
    if let startTime = responseDTO.startTime {
      self.startTime = startTime.toDateString(from: "HH:mm:ss", to: "a h:mm")
    }
    if let endDate = responseDTO.endDate {
      self.endDate = endDate.toDateString(from: "yyyy-MM-dd", to: "M월 d일")
    }
    if let endTime = responseDTO.endTime {
      self.endTime = endTime.toDateString(from: "HH:mm:ss", to: "a h:mm")
    }
    self.content = responseDTO.content
    self.location = responseDTO.location
    self.url = responseDTO.url
  }
}
