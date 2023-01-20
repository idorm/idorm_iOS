//
//  TimeManager.swift
//  idorm
//
//  Created by 김응철 on 2023/01/20.
//

import Foundation

enum TimeManager {
  
  static func postList(_ string: String) -> String {
    let result: String
    
    let format = DateFormatter()
    format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    format.timeZone = .init(abbreviation: "UTC")
    
    let postDate = format.date(from: string)!
    let currentDate = format.date(from: Date().ISO8601Format())!
    
    let interval = Int(currentDate.timeIntervalSince(postDate))
    
    switch interval {
    case 0..<60:
      result = "방금"
      
    case 60..<3600:
      result = "\(interval / 60)분 전"
      
    case 3600..<86400:
      result = "\(interval / 3600)시간 전"
      
    default:
      format.dateFormat = "MM/dd"
      result = format.string(from: postDate)
    }
    
    return result
  }
}
