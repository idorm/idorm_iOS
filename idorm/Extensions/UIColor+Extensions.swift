//
//  UIColor+Extensions.swift
//  idorm
//
//  Created by 김응철 on 2022/07/10.
//

import UIKit

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
  
  static var idorm_red: UIColor {
    return UIColor.init(rgb: 0xFF6868)
  }
}
