//
//  UITextField+Extensions.swift
//  idorm
//
//  Created by 김응철 on 2022/07/10.
//

import UIKit

extension UITextField {
  func addLeftPadding(_ padding: CGFloat) {
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.height))
    self.leftView = paddingView
    self.leftViewMode = ViewMode.always
  }
  
  func addRightPadding(_ padding: CGFloat) {
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.height))
    self.rightView = paddingView
    self.rightViewMode = ViewMode.always
  }
}
