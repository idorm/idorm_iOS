//
//  URLRequest+Extensions.swift
//  idorm
//
//  Created by 김응철 on 2022/08/15.
//

import UIKit
import RxSwift
import RxCocoa

enum HttpMethod: String {
  case get = "GET"
  case post = "POST"
}

struct Resource<T> {
  let url: URL
  var httpMethod: HttpMethod = .get
  var body: Data?
}

extension Resource {
  init(url: URL) {
    self.url = url
  }
}

extension URLRequest {
  static func load<T: Decodable>(resource: Resource<T>) -> Observable<T> {
    return Observable.just(resource.url)
      .flatMap { url -> Observable<Data> in
        let request = URLRequest(url: url)
        return URLSession.shared.rx.data(request: request)
      }
      .map { data -> T in
        return try JSONDecoder().decode(T.self, from: data)
      }
      .asObservable()
  }
}
