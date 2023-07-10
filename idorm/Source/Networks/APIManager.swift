//
//  APIManager.swift
//  idorm
//
//  Created by 김응철 on 6/26/23.
//

import RxSwift
import RxCocoa
import Moya

enum 

/// 네트워크와 관련된 처리를 수행하는 클래스입니다.
final class APIManager {
  
  // MARK: - Properties
  
  private let targetAPI: TargetType
  
  // MARK: - Initializer
  
  /// 초기값으로 `Provider`가 필요합니다.
  /// - Parameters:
  ///  - provider: Moya에서 제공하는 객체입니다.
  init(_ targetAPI: TargetType) {
    MoyaProvider<CommunityAPI>()
  }
  
  // MARK: - Functions
  
  /// 네트워크 요청을 합니다.
  /// - Parameters:
  /// -
  func requestAPI(by provider: MoyaProvider) -> Observable {
    
  }
}
