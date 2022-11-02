enum Gender: String {
  case male = "남자"
  case female = "여자"
  
  var parsingString: String {
    switch self {
    case .male:
      return "MALE"
    case .female:
      return "FEMALE"
    }
  }
}
