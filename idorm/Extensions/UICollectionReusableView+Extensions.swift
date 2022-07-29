//
//  UICollectionReusableView+Extensions.swift
//  idorm
//
//  Created by 김응철 on 2022/07/29.
//

import UIKit

extension UICollectionReusableView {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}
