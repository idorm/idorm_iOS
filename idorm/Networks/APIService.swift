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
  static func load(_ url: URLConvertible, httpMethod: HTTPMethod, body: Parameters?) -> Observable<AFDataResponse<Data>> {
    return Observable.create { observer in
      let header : HTTPHeaders = [
        "Content-Type" : "application/json"
      ]
      let request = AF.request(url, method: httpMethod, parameters: body, encoding: JSONEncoding.default, headers: header)
        .responseData { response in
          observer.onNext(response)
          observer.onCompleted()
        }
      return Disposables.create {
        request.cancel()
      }
    }
  }
  
  static func decode<T: Codable>(_ t: T.Type, data: Data) -> T {
    let decoder = JSONDecoder()
    guard let json = try? decoder.decode(T.self, from: data) else { fatalError("Encoding Error!") }
    return json
  }
}
