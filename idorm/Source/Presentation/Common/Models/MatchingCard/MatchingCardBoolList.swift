enum MatchingCardBoolList {
  case snoring
  case grinding
  case smoking
  case food
  case earphone
  
  var queryString: String {
    switch self {
    case .snoring:
      return "코골이"
    case .grinding:
      return "이갈이"
    case .smoking:
      return "흡연"
    case .food:
      return "실내음식"
    case .earphone:
      return "이어폰 착용"
    }
  }
}

