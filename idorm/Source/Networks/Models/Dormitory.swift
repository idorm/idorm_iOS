enum Dormitory: String, Codable {
  case no1 = "DORM1"
  case no2 = "DORM2"
  case no3 = "DORM3"
  
  var cardString: String {
    switch self {
    case .no1: return "1 기숙사"
    case .no2: return "2 기숙사"
    case .no3: return "3 기숙사"
    }
  }
}
