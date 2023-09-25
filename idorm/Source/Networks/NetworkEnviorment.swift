//
//  NetworkEnviorment.swift
//  idorm
//
//  Created by 김응철 on 9/23/23.
//

import Foundation

/**
 테스트할 서버를 분기처리 할 수 있습니다.
 */
enum NetworkEnviornment {
  /// 운영 서버
  case production
  /// 테스트 서버
  case develop
  
  var baseURL: URL {
    switch self {
    case .production:
      return URL(string: "https://idorm.inuappcenter.kr/api/v1")!
    case .develop:
      return URL(string: "http://ec2-43-200-211-165.ap-northeast-2.compute.amazonaws.com:8080/api/v1")!
    }
  }
}
