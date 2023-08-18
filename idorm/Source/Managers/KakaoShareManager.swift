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

/// KakaoSDK 라이브러리를 통해서 외부로 카카오톡 메세지를 보낼 수 있는 `KakaoShareManager`
final class KakaoShareManager {
  
  enum ShareType {
    case feed
    case teamCalendar
    
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
  
  /// 기본 이미지가 들어있는 하이퍼 링크
  private let defaultImageLink = "https://idorm-static.s3.ap-northeast-2.amazonaws.com/profileImage.png"
  
  // MARK: - Functions
  
  /// 회원을 카카오톡을 통해서 공유캘린더에 초대합니다.
  func inviteTeamCalendar(profileURL: String?, nickname: String, teamID: Int) {
    let profileURL: String = profileURL == nil ?
    self.defaultImageLink : profileURL!
    let templateArgs: [String: String] = [
      "senderNickNm": nickname,
      "userProfile": profileURL,
      "inviter": "\(teamID)"
    ]
    self.shareMessage(templateArgs, templateID: ShareType.teamCalendar.templateID)
  }
}

// MARK: - Privates

private extension KakaoShareManager {
  /// 데이터를 받아서 카카오톡 공유 메세지를 보냅니다.
  ///
  /// - Parameters:
  ///   - args: 키 값과 데이터 값이 들어있는 파라미터들
  ///   - templateID: 카카오톡 고유의 템플릿 식별자
  func shareMessage(_ args: [String: String], templateID: Int64) {
    if ShareApi.isKakaoTalkSharingAvailable() {
      ShareApi.shared.shareCustom(
        templateId: templateID,
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
      os_log(.error, "🔴 카카오톡이 해당 기기에 설치되어 있지 않습니다.")
    }
  }
}
