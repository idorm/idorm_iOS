enum MatchingImageViewType {
  /// 자신의 매칭 정보가 없을 떄
  case noMatchingInformation
  /// 상대방의 카드가 더이상 존재하지 않을 떄
  case noMatchingCardInformation
  /// 공유 버튼이 활성화가 되어 있지 않을 때
  case noShareState
  
  var imageName: String {
    switch self {
    case .noMatchingInformation: return "text_noMatchingInfo"
    case .noMatchingCardInformation: return "text_noMatchingCard"
    case .noShareState: return "text_noShare"
    }
  }
}
