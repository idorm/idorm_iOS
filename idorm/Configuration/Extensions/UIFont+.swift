//
//  UIFont+.swift
//  idorm
//
//  Created by 김응철 on 2023/01/23.
//

import UIKit

extension UIFont {
  
  enum Font: String {
    case bold = "NotoSansCJKkr-Bold"
    case regular = "NotoSansCJKkr-Regular"
    case medium = "NotoSansCJKkr-Medium"
  }
  
  static func idormFont(_ font: Font, size: CGFloat) -> UIFont {
    let idormFont = UIFont(name: font.rawValue, size: size)!
    return idormFont
  }
}
