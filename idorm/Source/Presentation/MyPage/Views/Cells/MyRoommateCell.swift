import UIKit

import SnapKit
import Then

final class MyRoommateCell: UITableViewCell {
  
  // MARK: - Properties
  
  static let identifier = "MyRoommateCell"
  
  var matchingCard: MatchingCard!
  
  // MARK: - Setup
  
  func setupMatchingInfomation(from info: MatchingMember) {
    let matchingCard = MatchingCard(myInfo: info)
    self.matchingCard = matchingCard
    setupStyles()
    setupLayout()
    setupConstraints()
  }
  
  private func setupStyles() {
    backgroundColor = .white
  }
  
  private func setupLayout() {
    contentView.addSubview(matchingCard)
  }
  
  private func setupConstraints() {
    matchingCard.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(24)
      make.leading.trailing.equalToSuperview().inset(24)
      make.centerX.equalToSuperview()
      make.height.equalTo(431)
    }
  }
}
