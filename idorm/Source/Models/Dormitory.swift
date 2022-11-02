enum Dormitory: String {
  case no1 = "1 기숙사"
  case no2 = "2 기숙사"
  case no3 = "3 기숙사"
  
  var getString: String {
    switch self {
    case .no1:
      return "DORM1"
    case .no2:
      return "DORM2"
    case .no3:
      return "DORM3"
    }
  }
}
