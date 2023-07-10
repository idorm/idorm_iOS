//
//  CalendarsResponseModel.swift
//  idorm
//
//  Created by 김응철 on 7/10/23.
//

import Foundation

struct CalendarsResponseModel: Codable {
  let isSleepover: Bool
  let startDate: Date
  
}

{
  "isSleepover": false,
  "startDate": "2023-04-27",
  "targets": [
    {
      "memberId": 10,
      "nickname": "도미",
      "order": 1,
      "profilePhotoUrl": "사진 url"
    }
  ],
  "teamCalendarId": 1,
  "title": "청소"
}
