//
//  NetworkUtility.swift
//  idorm
//
//  Created by 김응철 on 7/11/23.
//

import Foundation

enum NetworkUtility {
  
  // MARK: - Static
  
  /// 현재 테스트할 서버입니다.
  static var networkEnviornment: NetworkEnviornment = .develop
  
  /// 서버의 응답을 원하는 구조체로 변환하는 메서드입니다.
  ///
  /// - Parameters:
  ///  - t: 변환할 타입입니다.
  ///  - data: 서버에서 응답한 `response`의 `data`타입입니다.
  static func decode<T: Decodable>(_ t: T.Type, data: Data) -> T {
    let decoder = JSONDecoder()
    guard let json = try? decoder.decode(T.self, from: data) else {
      fatalError("⚙️ decode를 실패했습니다! 실패유형: \(t)")
    }
    return json
  }  
}
