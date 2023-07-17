//
//  UICollectionReusableView+.swift
//  idorm
//
//  Created by 김응철 on 7/16/23.
//

import UIKit

extension UICollectionReusableView {
  static var identifier: String {
    return String(describing: Self.self)
  }
}
