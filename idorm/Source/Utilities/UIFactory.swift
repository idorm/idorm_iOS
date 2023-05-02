//
//  UIFactory.swift
//  idorm
//
//  Created by 김응철 on 2023/01/27.
//

import UIKit

enum UIFactory {}

extension UIFactory {
  static func label(_ title: String, textColor: UIColor, font: UIFont) -> UILabel {
    let lb = UILabel()
    lb.text = title
    lb.textColor = textColor
    lb.font = font
    
    return lb
  }
  
  static func view(_ color: UIColor) -> UIView {
    let view = UIView()
    view.backgroundColor = color
    
    return view
  }
  
  static func button(_ imageName: String) -> UIButton {
    let btn = UIButton()
    btn.setImage(UIImage(named: imageName), for: .normal)
    
    return btn
  }
}
