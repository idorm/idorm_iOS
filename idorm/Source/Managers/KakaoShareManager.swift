//
//  KakaoShareManager.swift
//  idorm
//
//  Created by 김응철 on 8/17/23.
//

import UIKit
import OSLog

import KakaoSDKCommon
import KakaoSDKShare
import KakaoSDKTemplate
import RxSwift
import RxCocoa

/// KakaoSDK 라이브러리를 통해서 외부로 카카오톡 메세지를 보낼 수 있는 `KakaoShareManager`
///
/// 이 클래스는 싱글톤입니다.
final class KakaoShareManager {
  
  enum ShareType {
    case feed(postID: Int)
    case teamCalendar(memberID: Int)
    
    var parameter: String {
      switch self {
      case .feed:
        return "contentId"
      case .teamCalendar:
        return "inviter"
      }
    }
    
    /// 템플릿 고유값
    var templateID: Int64 {
      switch self {
      case .feed:
        return Int64(93479)
      case .teamCalendar:
        return Int64(97215)
      }
    }
  }
  
  // MARK: - Properties
  
  static let shared = KakaoShareManager()
  private let disposeBag = DisposeBag()
  
  var topViewController: UIViewController {
    return UIApplication.shared.topViewController()
  }
  
  /// 기본 이미지가 들어있는 하이퍼 링크
  private let defaultImageLink = "https://idorm-static.s3.ap-northeast-2.amazonaws.com/profileImage.png"
  
  // MARK: - Initializer
  
  private init() {}
  
  // MARK: - Functions
  
  /// 회원을 카카오톡을 통해서 공유캘린더에 초대합니다.
  func inviteTeamCalendar(profileURL: String?, nickname: String, inviter: Int) {
    let profileURL: String = profileURL == nil ?
    self.defaultImageLink : profileURL!
    let templateArgs: [String: String] = [
      "senderNickNm": nickname,
      "userProfile": profileURL,
      "inviter": "\(inviter)"
    ]
    self.shareMessage(templateArgs, shareType: .teamCalendar(memberID: inviter))
  }
  
  /// 카카오톡에서 메세지를 클릭했을 때 실행되는 메서드입니다.
  /// `DeepLink`를 통해서 앱 상호작용을 결정합니다.
  ///
  /// - Parameters:
  ///   - url: `URL Schemes`를 통해 들어온 `URL`입니다.
  func handleKakaoMessageDeepLink(_ url: URL?) {
    guard let url = url,
          let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let queryItem = urlComponents.queryItems?.first
    else { return }
    if self.topViewController is iDormSplashViewController {
      // 아직 스플래시 화면일 때
      guard let launchVC = self.topViewController as? iDormSplashViewController else { return }
      launchVC.dismissCompletion = {
        self.handleNetworkProcess(queryItem)
      }
    } else {
      self.handleNetworkProcess(queryItem)
    }
  }
}

// MARK: - Privates

private extension KakaoShareManager {
  /// 카카오톡 공유 메세지에 대해서 알맞는 요청을 보냅니다.
  ///
  /// - Parameters:
  ///   - queryItem: URL에 담겨있는 `query`값을 전달합니다.
  func handleNetworkProcess(_ queryItem: URLQueryItem) {
    guard let value = queryItem.value else { return }
    let parameter = queryItem.name
    
    switch parameter {
    case "contentId": // 게시글 공유
      guard let postIdentifier = Int(value) else { return }
      DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
//        TransitionManager.shared.postPushAlarmDidTap?(postIdentifier)
      })
    case "inviter": // 공유 캘린더 초대
      guard let inviterIdentifier = Int(value) else { return }
      NetworkService<CalendarAPI>().requestAPI(
        to: .postAcceptInvitation(memberID: inviterIdentifier)
      )
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in }
      .disposed(by: self.disposeBag)
    default:
      break
    }
  }
  
  /// 데이터를 받아서 카카오톡 공유 메세지를 보냅니다.
  ///
  /// - Parameters:
  ///   - args: 키 값과 데이터 값이 들어있는 파라미터들
  ///   - templateID: 카카오톡 고유의 템플릿 식별자
  func shareMessage(_ args: [String: String], shareType: ShareType) {
    if ShareApi.isKakaoTalkSharingAvailable() {
      ShareApi.shared.shareCustom(
        templateId: shareType.templateID,
        templateArgs: args) { result, error in
          if let error {
            os_log(.error, "🔴 카카오톡 공유하기 과정에서 오류가 발생했습니다. \(error.localizedDescription)")
          } else {
            if let result {
              UIApplication.shared.open(result.url)
            } else {
              os_log(.error, "🔴 결과값이 유효하지 않습니다.")
            }
          }
        }
    } else {
      // 카카오톡 앱스토어 페이지로 이동합니다.
      let kakaoUrl = URL(string: "https://accounts.kakao.com")!
      UIApplication.shared.open(kakaoUrl)
      os_log(.error, "🔴 카카오톡이 해당 기기에 설치되어 있지 않습니다.")
    }
  }
}
