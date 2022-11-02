enum JoinPeriod: String {
  case period_16 = "16 주"
  case period_24 = "24 주"
  
  var getString: String {
    switch self {
    case .period_16:
      return "WEEK16"
    case .period_24:
      return "WEEK24"
    }
  }
}
