//
//  Constant.swift
//  idorm
//
//  Created by 김응철 on 2023/03/12.
//

struct URLConstants {
  static let production = "https://idorm.inuappcenter.kr/api/v1"
  static let develop = "http://ec2-43-200-211-165.ap-northeast-2.compute.amazonaws.com:8080/api/v1"
  static let termsOfService = "https://idorm.notion.site/e5a42262cf6b4665b99bce865f08319b"
}

struct KeyConstants {
  static let appKEY = "a8df1fc9d307130a9d3ee6503549c92b"
}

struct DateFormat {
  static let teamCalendar = "M월 d일"
  static let calendarManagement = "MM월 dd일 (E)"
  static let DTO = "yyyy-MM-dd"
}

struct TimeFormat {
  static let teamCalendar = "a h:mm"
  static let calendarManagement = "a h시~"
  static let DTO = "HH:mm:ss"
}
