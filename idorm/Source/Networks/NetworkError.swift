//
//  APIError.swift
//  idorm
//
//  Created by 김응철 on 6/26/23.
//

import Foundation

import Moya
import Alamofire

enum NetworkError: Error {
  case empty
  case timeout(Error)
  case internetConnection(Error)
  case restError(errorCode: String?, errorMessage: String?)
}

extension NetworkError {
  /// `Error` 타입을 `URLError`로 바꿉니다.
  static func convertToURLError(_ error: Error) -> URLError? {
    switch error {
    case let MoyaError.underlying(afError as AFError, _):
      fallthrough
    case let afError as AFError:
      return afError.underlyingError as? URLError
    case let MoyaError.underlying(urlError as URLError, _):
      fallthrough
    case let urlError as URLError:
      return urlError
    default:
      return nil
    }
  }
  
  /// 인터넷에 연결되어 있는지를 판별합니다.
  static func isNotConnection(error: Error) -> Bool {
    Self.convertToURLError(error)?.code == .notConnectedToInternet
  }
  
  /// 중간에 인터넷 연결이 끊어졌는지를 판별합니다.
  static func isLostConnection(error: Error) -> Bool {
    switch error {
    case let AFError.sessionTaskFailed(error: posixError as POSIXError)
      where posixError.code == .ECONNABORTED:
      break
    case let MoyaError.underlying(urlError as URLError, _):
      fallthrough
    case let urlError as URLError:
      guard urlError.code == URLError.networkConnectionLost else { fallthrough }
      break
    default:
      return false
    }
    return true
  }
}
