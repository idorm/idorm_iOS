//
//  Sequence+.swift
//  idorm
//
//  Created by 김응철 on 2023/02/11.
//

import Foundation

extension Sequence where Element: Hashable {
  func uniqued() -> [Element] {
    var set = Set<Element>()
    return filter { set.insert($0).inserted }
  }
}
