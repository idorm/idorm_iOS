enum MatchingImageViewType {
  case noMatchingInformation
  case noMatchingCard
  
  var imageName: String {
    switch self {
    case .noMatchingInformation: return "noMatchingInfomation"
    case .noMatchingCard: return "noCardInfomation"
    }
  }
}
