//
//  TimeManager.swift
//  idorm
//
//  Created by 김응철 on 2023/01/20.
//

import Foundation

enum TimeUtils {
  
  static let format = "yyyy-MM-dd'T'HH:mm:ss'Z'"
  
  static func postList(_ string: String) -> String {
    let result: String

    let formatter = DateFormatter()
    formatter.dateFormat = format
    formatter.timeZone = .init(abbreviation: "UTC")
    
    let postDate = formatter.date(from: string)!
    let currentDate = formatter.date(from: Date().ISO8601Format())!
    
    let interval = Int(currentDate.timeIntervalSince(postDate))
    
    switch interval {
    case 0..<60:
      result = "방금"
      
    case 60..<3600:
      result = "\(interval / 60)분 전"
      
    case 3600..<86400:
      result = "\(interval / 3600)시간 전"
      
    default:
      formatter.dateFormat = "MM/dd"
      result = formatter.string(from: postDate)
    }
    
    return result
  }
  
  static func detailPost(_ string: String) -> String {
    
    let formatter = DateFormatter()
    formatter.dateFormat = format
    formatter.timeZone = .init(abbreviation: "UTC")
    
    var postDate = formatter.date(from: string)!
    postDate.addTimeInterval(32400)
    formatter.dateFormat = "MM'/'dd HH:mm"
    
    return formatter.string(from: postDate)
  }
}
