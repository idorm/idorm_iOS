enum JoinPeriod: String, Codable {
  case period_16 = "WEEK16"
  case period_24 = "WEEK24"
  
  var parsingString: String {
    switch self {
    case .period_16:
      return "WEEK16"
    case .period_24:
      return "WEEK24"
    }
  }
  
  var cardString: String {
    switch self {
    case .period_16: return "짧은 기간"
    case .period_24: return "긴 기간"
    }
  }
}
