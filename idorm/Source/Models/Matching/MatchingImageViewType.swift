enum MatchingImageViewType {
  /// 자신의 매칭 정보가 없을 떄
  case noMatchingInformation
  /// 상대방의 카드가 더이상 존재하지 않을 떄
  case noMatchingCardInformation
  
  var imageName: String {
    switch self {
    case .noMatchingInformation: return "noMatchingInfomation"
    case .noMatchingCardInformation: return "noCardInfomation"
    }
  }
}
