//
//  UIView+Extensions.swift
//  idorm
//
//  Created by 김응철 on 2022/07/11.
//

import UIKit

public extension UIView {
  func addBottomBorderWithColor(color: UIColor) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    border.frame = CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: 1)
    self.layer.addSublayer(border)
  }
  
  func addAboveTheBottomBorderWithColor(color: UIColor) {
    let border = CALayer()
    border.backgroundColor = color.cgColor
    border.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
    self.layer.addSublayer(border)
  }
}
