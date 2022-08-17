//
//  URLRequest+Extensions.swift
//  idorm
//
//  Created by 김응철 on 2022/08/15.
//

import UIKit
import RxSwift
import RxCocoa

enum NetworkError: Error {
  case decodingError
  case domainError
  case urlError
}

enum HttpMethod: String {
  case get = "GET"
  case post = "POST"
}

struct Resource<T: Codable> {
  let url: URL
  var httpMethod: HttpMethod = .get
  var body: Data?
}

extension Resource {
  init(url: URL) {
    self.url = url
  }
}
//
//extension URLRequest {
//  static func load<T: Decodable>(resource: Resource<T>) -> Observable<T> {
//    return Observable.just(resource.url)
//      .flatMap { url -> Observable<HTTPURLResponse, Data> in
//        var request = URLRequest(url: url)
//        request.httpMethod = resource.httpMethod.rawValue
//        request.httpBody = resource.body
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        return URLSession.shared.rx.response(request: request)
//      }
//      .map { response -> T in
//        return try JSONDecoder().decode(T.self, from: data)
//      }
//  }
//}
