struct MatchingFilter: Codable {
  var dormNum: Dormitory
  var isAllowedFood: Bool
  var isGrinding: Bool
  var isSmoking: Bool
  var isSnoring: Bool
  var isWearEarphones: Bool
  var joinPeriod: JoinPeriod
  var minAge: Int
  var maxAge: Int
  
  static func initialValue() -> MatchingFilter {
    return MatchingFilter(dormNum: .no1, isAllowedFood: false, isGrinding: false, isSmoking: false, isSnoring: false, isWearEarphones: false, joinPeriod: .period_16, minAge: 20, maxAge: 30)
  }
}
