//
//  UIImage+.swift
//  idorm
//
//  Created by 김응철 on 7/8/23.
//

import UIKit

enum iDormIcon: String {
  case left
  case right
  case calendar
  case option
  case cancel
  case pencil
  case pencil2
  case human
  
  case deselect
  case select
}

enum iDormText: String {
  case inviteRoommate
}

extension UIImage {
  /// `UIImage` 타입인 아이콘을 추출합니다.
  ///
  /// - Parameters:
  ///  - icon: 원하는 아이콘의 케이스
  ///
  /// - returns:
  /// 원하는 아이콘의 `UIimage`
  static func iDormIcon(_ icon: iDormIcon) -> UIImage? {
    return UIImage(named: "ic_\(icon.rawValue)")
  }
  
  /// `UIImage` 타입인 텍스트(이미지)를 추출합니다.
  ///
  /// - Parameters:
  ///  - text: 원하는 텍스트 이미지
  ///
  /// - returns:
  /// 원하는 텍스트 이미지의 `UIImage`
  static func iDormText(_ text: iDormText) -> UIImage? {
    return UIImage(named: "txt_\(text.rawValue)")
  }
}
