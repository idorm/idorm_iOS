//
//  FilterStorage.swift
//  idorm
//
//  Created by 김응철 on 2022/12/19.
//

import Foundation

final class FilterStorage {
  
  static let shared = FilterStorage()
  private init() {}
  
  private(set) var filter = MatchingDTO.Filter()
  var hasFilter: Bool = false
  
  func saveFilter(_ filter: MatchingDTO.Filter) {
    self.filter = filter
  }
  
  func resetFilter() {
    self.filter = MatchingDTO.Filter()
  }
}
