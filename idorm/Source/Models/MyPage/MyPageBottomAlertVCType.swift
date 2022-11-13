enum MyPageBottomAlertVCType {
  case like
  case dislike
  
  var height: Int {
    switch self {
    case .like: return 208
    case .dislike: return 208
    }
  }
}
