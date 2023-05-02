//
//  BaseAPI.swift
//  idorm
//
//  Created by 김응철 on 2023/01/27.
//

import Foundation

import Moya

protocol BaseAPI {
  func getJsonHeader() -> [String: String]
  func getMultipartHeader() -> [String: String]
  func getBaseURL() -> URL
  func getPath() -> String
  func getMethod() -> Moya.Method
  func getTask() -> Task
}

extension BaseAPI {
  func getJsonHeader() -> [String: String] {
    return [
      "Content-Type": "application/json",
      "X-AUTH-TOKEN": UserStorage.shared.token
    ]
  }
  
  func getMultipartHeader() -> [String: String] {
    return [
      "Content-Type": "multipart/form-data",
      "X-AUTH-TOKEN": UserStorage.shared.token
    ]
  }
  
  func getBaseURL() -> URL {
    return URL(string: "https://idorm.inuappcenter.kr")!
  }
  
  static func decode<T: Decodable>(_ t: T.Type, data: Data) -> T {
    let decoder = JSONDecoder()
    guard let json = try? decoder.decode(T.self, from: data) else { fatalError("Decoding Error!") }
    return json
  }
}
