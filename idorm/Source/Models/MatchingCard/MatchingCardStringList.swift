enum MatchingCardStringList {
  case wakeUp
  case cleanUp
  case showerTime
  case mbti
  
  var title: String {
    switch self {
    case .wakeUp:
      return "기상시간"
    case .cleanUp:
      return "정리정돈"
    case .showerTime:
      return "샤워시간"
    case .mbti:
      return "MBTI"
    }
  }
}
