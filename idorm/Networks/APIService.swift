//
//  APIService.swift
//  idorm
//
//  Created by 김응철 on 2022/09/06.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

typealias ServerResponse = Observable<(response: HTTPURLResponse, data: Data)>

enum NetworkType: String {
  case get = "GET"
  case post = "POST"
  case fetch = "FETCH"
}

enum ServerError: Error {
  case unAuthorized
  case forbidden
  case errorMessage
}

class APIService {
  static func load(_ url: URLConvertible, httpMethod: HTTPMethod, body: Parameters) -> Observable<Data?> {
    return Observable.create { observer in
      let header : HTTPHeaders = [
          "Content-Type" : "application/json"
      ]
      
      let request = AF.request(url, method: httpMethod, parameters: body, encoding: JSONEncoding.default, headers: header)
        .validate(statusCode: 200..<300)
        .responseData { response in
          switch response.result {
          case .success(let data):
            observer.onNext(data)
            observer.onCompleted()
          case .failure(let error):
            switch response.response?.statusCode {
            case 400:
              observer.onError(ServerError.errorMessage)
            case 401:
              observer.onError(ServerError.unAuthorized)
            case 403:
              observer.onError(ServerError.forbidden)
            default:
              observer.onError(error)
            }
          }
        }
      return Disposables.create {
        request.cancel()
      }
    }
  }
}

