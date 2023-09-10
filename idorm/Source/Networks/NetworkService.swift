//
//  NetworkManager.swift
//  idorm
//
//  Created by 김응철 on 6/26/23.
//

import UIKit

import Alamofire
import RxSwift
import RxCocoa
import Moya
import OSLog

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

/**
 네트워크와 관련된 처리를 수행하는 클래스입니다.
 
 - 이 클래스는 싱클톤입니다.
 - 제네릭으로 `targetType`이 필요합니다.
*/
final class NetworkService<targetType: BaseTargetType> {
  
  // MARK: - Properties
  
  private let provider = MoyaProvider<targetType>()
  
  // MARK: - Initializer
  
  // MARK: - Functions
  
  /// 네트워크 요청을 합니다.
  ///
  /// - Parameters:
  ///   - targetAPI: 어떤 API를 호출한건지 정합니다.
  func requestAPI(to targetAPI: targetType) -> Observable<Response> {
    guard
      let topViewController = UIApplication.shared.topViewController() as? BaseViewController
    else {
      os_log(.error, "📺 최상위 컨트롤러가 BaseVC가 아닙니다!")
      return .empty()
    }
    topViewController.isLoading = true
    
    return self.provider.rx
      .request(targetAPI)
      .filterSuccessfulStatusCodes()
      .catch(self.handleInternetConnection)
      .catch(self.handleTimeOut)
      .catch(self.handleREST)
      .retry(3)
      .do(
        onSuccess: { response in
          topViewController.isLoading = false
          os_log(
            .info, "🟢 요청에 성공했습니다! API: \(targetAPI.baseURL.absoluteString + targetAPI.path)"
          )
        },
        onError: { rawError in
          topViewController.isLoading = false
          switch rawError {
          case NetworkError.timeout:
            os_log(.error, "❌ 요청에 실패했습니다. 실패요인: TimeOut")
            AlertManager.shared.showAlertPopup("요청 시간이 초과되었습니다.")
          case NetworkError.internetConnection:
            os_log(.error, "❌ 요청에 실패했습니다. 실패요인: 인터넷 연결 끊김")
            AlertManager.shared.showAlertPopup("인터넷 연결을 확인해주세요.")
          case let NetworkError.restError(errorCode, errorMessage):
            os_log(.error, "❌ 요청에 실패했습니다. 실패요인: \(errorCode!)")
            AlertManager.shared.showAlertPopup(errorMessage)
          default:
            os_log(.error, "❌ 알수없는 에러가 발생했습니다. 실패요인: \(rawError.localizedDescription)")
            break
          }
        }
      )
      .asObservable()
  }
}

// MARK: - Error Handling

extension NetworkService {
  /// 인터넷 연결 상태를 확인하고 에러 종류를 반환합니다.
  func handleInternetConnection<T: Any>(_ error: Error) throws -> Single<T> {
    guard
      let urlError = NetworkError.convertToURLError(error),
      NetworkError.isNotConnection(error: error)
    else { throw error }
    throw NetworkError.internetConnection(urlError)
  }
  
  /// 요청 시간이 초과 되었을 때 에러 종류를 반환합니다.
  func handleTimeOut<T: Any>(_ error: Error) throws -> Single<T> {
    guard
      let urlError = NetworkError.convertToURLError(error),
      urlError.code == .timedOut
    else { throw error }
    throw NetworkError.timeout(urlError)
  }
  
  /// 에러코드가 400이상 관련된 에러들의 종류를 판단하고 반환합니다.
  func handleREST<T: Any>(_ error: Error) throws -> Single<T> {
    guard error is NetworkError else {
      let response = try (error as? MoyaError)?.response?.mapJSON() as? [String: Any]
      let errorCode = response?["responseCode"] as? String
      let errorMessage = response?["responseMessage"] as? String
      throw NetworkError.restError(errorCode: errorCode, errorMessage: errorMessage)
    }
    throw error
  }
}
