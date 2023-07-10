//
//  APIManager+ErrorHandling.swift
//  idorm
//
//  Created by 김응철 on 7/7/23.
//

import Foundation

import Moya
import RxSwift
import RxCocoa

extension APIManager {
  /// 인터넷 연결 상태를 확인하고 에러 종류를 반환합니다.
  func handleInternetConnection<T: Any>(_ error: Error) throws -> Single<T> {
    guard
      let urlError = APIError.convertToURLError(error),
      APIError.isNotConnection(error: error)
    else { throw error }
    throw APIError.internetConnection(urlError)
  }
  
  /// 요청 시간이 초과 되었을 때 에러 종류를 반환합니다.
  func handleTimeOut<T: Any>(_ error: Error) throws -> Single<T> {
    guard
      let urlError = APIError.convertToURLError(error),
      urlError.code == .timedOut
    else { throw error }
    throw APIError.timeout(urlError)
  }
  
  /// 에러코드가 400이상 관련된 에러들의 종류를 판단하고 반환합니다.
  func handleREST<T: Any>(_ error: Error) throws -> Single<T> {
    guard error is APIError else {
      let response = try (error as? MoyaError)?.response?.mapJSON() as? [String: Any]
      let errorCode = response?["responseCode"] as? String
      let errorMessage = response?["responseMessage"] as? String
      throw APIError.restError(errorCode: errorCode, errorMessage: errorMessage)
    }
    throw error
  }
}
