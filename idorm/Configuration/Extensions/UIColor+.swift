//
//  UIColor+Extensions.swift
//  idorm
//
//  Created by 김응철 on 2022/07/10.
//

import UIKit

enum iDormColor: Int {
  case firstUser = 0xB336FF
  case secondUser = 0xFECD50
  case thirdUser = 0x2AB577
  case fourthUser = 0xFF54B0
  
  case iDormGray100 = 0xF2F5FA
  case iDormGray200 = 0xE3E1EC
  case iDormGray300 = 0x9B9B9B
  case iDormGray400 = 0x5B5B5B
  case iDormBlue = 0x71A1FE
  case iDormRed = 0xFF6868
  case iDormMatchingScreen = 0xF8FDFF
}

extension UIColor {
  /// 디자인 시스템에 있는 컬러를 추출합니다.
  /// - Parameters:
  ///  - color: 사용할 컬러의 `case`를 주입합니다.
  static func iDormColor(_ color: iDormColor) -> UIColor {
    return UIColor.init(rgb: color.rawValue)
  }
}

extension UIColor {
  convenience init(red: Int, green: Int, blue: Int, a: Int = 0xFF) {
    self.init(
      red: CGFloat(red) / 255.0,
      green: CGFloat(green) / 255.0,
      blue: CGFloat(blue) / 255.0,
      alpha: CGFloat(a) / 255.0
    )
  }
  
  convenience init(rgb: Int) {
    self.init(
      red: (rgb >> 16) & 0xFF,
      green: (rgb >> 8) & 0xFF,
      blue: rgb & 0xFF
    )
  }
  
  convenience init(argb: Int) {
    self.init(
      red: (argb >> 16) & 0xFF,
      green: (argb >> 8) & 0xFF,
      blue: argb & 0xFF,
      a: (argb >> 24) & 0xFF
    )
  }
  
  static var idorm_blue: UIColor {
    return UIColor.init(rgb: 0x71A1FE)
  }
  
  static var idorm_gray_300: UIColor {
    return UIColor.init(rgb: 0x9B9B9B)
  }
  
  static var idorm_gray_400: UIColor {
    return UIColor.init(rgb: 0x5B5B5B)
  }
  
  static var idorm_gray_200: UIColor {
    return UIColor.init(rgb: 0xE3E1EC)
  }
  
  static var idorm_gray_100: UIColor {
    return UIColor.init(rgb: 0xF2F5FA)
  }
  
  static var idorm_yellow: UIColor {
    return UIColor.init(rgb: 0xFACD5B)
  }
  
  static var idorm_yellow2: UIColor {
    return UIColor.init(rgb: 0xFFDD87)
  }
  
  static var idorm_red: UIColor {
    return UIColor.init(rgb: 0xFF6868)
  }
  
  static var idorm_card: UIColor {
    return UIColor.init(rgb: 0x8EC2FF)
  }
  
  static var idorm_green: UIColor {
    return UIColor.init(rgb: 0x60D989)
  }
  
  static var idorm_matchingScreen: UIColor {
    return .init(rgb: 0xF8FDFF)
  }
}
