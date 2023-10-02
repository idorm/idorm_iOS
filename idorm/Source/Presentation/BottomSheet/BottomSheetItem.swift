//
//  BottomSheetItem.swift
//  idorm
//
//  Created by 김응철 on 7/24/23.
//

import UIKit

enum BottomSheetItem {
  case normal(title: String, image: UIImage? = nil)
  
  // General
  case blockUser
  case reportUser
  
  // PostList
  case dormitory(Dormitory)
  
  // Community
  case deleteComment(commentID: Int)
  case deletePost
  case editPost
  case sharePost
  
  // Calendar
  case manageFriend
  case manageCalendar
  case shareCalendar
  case exitCalendar
  
  var itemHeight: CGFloat {
    switch self {
    case .reportUser:
      return 71.0
    default:
      return 40.0
    }
  }
  
  /// 각 케이스에 맞는 버튼을 추출합니다.
  var button: iDormButton {
    let button: iDormButton
    switch self {
    case .blockUser:
      button = .init("사용자 차단", image: .iDormIcon(.block))
    case .deleteComment:
      button = .init("댓글 삭제", image: .iDormIcon(.trashcan))
    case .reportUser:
      button = .init("신고하기", image: nil)
      button.subTitle = "idorm의 커뮤니티 가이드라인에 위배되는 댓글"
      button.subTitleFont = .iDormFont(.medium, size: 14.0)
      button.subTitleColor = .iDormColor(.iDormGray400)
    case .sharePost:
      button = .init("공유하기", image: .iDormIcon(.share))
    case .deletePost:
      button = .init("게시글 삭제", image: .iDormIcon(.trashcan))
    case .editPost:
      button = .init("게시글 수정", image: .iDormIcon(.note))
    case .manageFriend:
      button = .init("친구 관리", image: nil)
    case .manageCalendar:
      button = .init("일정 관리", image: nil)
    case .shareCalendar:
      button = .init("룸메이트 초대해서 일정 공유하기", image: nil)
    case .exitCalendar:
      button = .init("일정 공유 캘린더 나가기", image: nil)
    case .normal:
      return iDormButton("", image: nil)
    case .dormitory(let dormitory):
      button = .init(dormitory.postListString)
    }
    // Configuration
    button.baseForegroundColor = .black
    button.baseBackgroundColor = .white
    button.titleAlignment = .leading
    button.imagePadding = 8.0
    button.imageSize = 20.0
    button.configurationUpdateHandler = self.getButtonUpdateHandler()
    button.bottomSheetItem = self
    button.contentHorizontalAlignment = .leading
    switch self {
    case .dormitory:
      button.font = .iDormFont(.bold, size: 20.0)
    default:
      button.font = .iDormFont(.medium, size: 20.0)
    }
    return button
  }
}

extension BottomSheetItem {
  func getButtonUpdateHandler() -> UIButton.ConfigurationUpdateHandler {
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .highlighted:
        button.configuration?.baseBackgroundColor = .iDormColor(.iDormGray100)
      default:
        button.configuration?.baseBackgroundColor = .white
      }
    }
    return handler
  }}
