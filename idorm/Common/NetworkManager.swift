//
//  NetworkManager.swift
//  idorm
//
//  Created by 김응철 on 2022/08/25.
//

import Foundation
import RxSwift
import RxCocoa

typealias ResponseResult = Observable<(response: HTTPURLResponse, data: Data)>
