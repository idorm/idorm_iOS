//
//  BaseAPI.swift
//  idorm
//
//  Created by 김응철 on 2023/01/27.
//

import Foundation

import Moya

protocol BaseTargetType: TargetType {
  func getPath() -> String
  func getMethod() -> Moya.Method
  func getTask() -> Task
  func getHeader() -> NetworkHeaderType
}

extension BaseTargetType {
  func getBaseURL() -> URL {
    return URL(string: URLConstants.develop)!
  }
}
