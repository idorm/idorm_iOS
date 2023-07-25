//
//  APIManager.swift
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

/// 네트워크와 관련된 처리를 수행하는 클래스입니다.
final class APIManager<targetType: TargetType> {
  
  // MARK: - Properties

  private let provider = MoyaProvider<targetType>()
  
  // MARK: - Initializer
  
  // MARK: - Functions
  
  /// 네트워크 요청을 합니다.
  /// - Parameters:
  ///  - targetAPI: 어떤 API를 호출한건지 정합니다.
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
          case APIError.timeout:
            os_log(.error, "❌ 요청에 실패했습니다. 실패요인: TimeOut")
            AlertManager.shared.showAlertPopup("요청 시간이 초과되었습니다.")
          case APIError.internetConnection:
            os_log(.error, "❌ 요청에 실패했습니다. 실패요인: 인터넷 연결 끊김")
            AlertManager.shared.showAlertPopup("인터넷 연결을 확인해주세요.")
          case let APIError.restError(errorCode, errorMessage):
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
