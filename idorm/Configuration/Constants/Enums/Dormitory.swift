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
  
  var postListString: String {
    switch self {
    case .no1: return "인천대 1기숙사"
    case .no2: return "인천대 2기숙사"
    case .no3: return "인천대 3기숙사"
    }
  }
}
