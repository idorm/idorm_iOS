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
}

extension UIImage {
  /// UIImage 타입인 아이콘을 추출합니다.
  /// - Parameters:
  ///  - icon: 원하는 아이콘의 케이스
  static func iDormIcon(_ icon: iDormIcon) -> UIImage? {
    return UIImage(named: "ic_\(icon.rawValue)")
  }
}
