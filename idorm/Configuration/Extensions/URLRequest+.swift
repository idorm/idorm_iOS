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
