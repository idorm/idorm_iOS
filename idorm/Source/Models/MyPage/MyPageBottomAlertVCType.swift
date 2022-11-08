enum MyPageBottomAlertVCType {
  case like
  case dislike
  
  var height: Int {
    switch self {
    case .like: return 171
    case .dislike: return 171
    }
  }
}
