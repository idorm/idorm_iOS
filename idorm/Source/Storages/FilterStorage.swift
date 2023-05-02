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
  
  private(set) var filter = MatchingRequestModel.Filter()
  var hasFilter: Bool = false
  
  func saveFilter(_ filter: MatchingRequestModel.Filter) {
    self.filter = filter
  }
  
  func resetFilter() {
<<<<<<< HEAD:idorm/Configuration/Storages/FilterStorage.swift
    self.filter = MatchingDTO.Filter()
=======
    self.filter = MatchingRequestModel.Filter()
    self.hasFilter = false
>>>>>>> dev:idorm/Source/Storages/FilterStorage.swift
  }
}
