//
//  UITabBar+.swift
//  idorm
//
//  Created by 김응철 on 9/30/23.
//

import UIKit

extension UITabBar {
  func updateBackgroundColor(_ color: UIColor) {
    let appearance = UITabBarAppearance()
    appearance.backgroundColor = color
    self.standardAppearance = appearance
    self.scrollEdgeAppearance = appearance
  }
}
