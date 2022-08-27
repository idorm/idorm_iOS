//
//  NetworkManager.swift
//  idorm
//
//  Created by 김응철 on 2022/08/25.
//

import Foundation
import RxSwift
import RxCocoa

typealias ServerResponse = Observable<(response: HTTPURLResponse, data: Data)>

enum NetworkType: String {
  case get = "GET"
  case post = "POST"
  case fetch = "FETCH"
}

