import UIKit

import SnapKit
import Then

final class MatchingCardWishTextView: UIView {
  
  // MARK: - Properties
  
  private var contentsLabel: UILabel!
  
  private let matchingMember: MatchingMember
  
  // MARK: - LifeCycle
  
  init(_ matchingMember: MatchingMember) {
    self.matchingMember = matchingMember
    super.init(frame: .zero)
    setupContentsLabel()
    setupStyles()
    setupLayout()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupContentsLabel() {
    let contentsLabel = UILabel()
    contentsLabel.font = .init(name: MyFonts.medium.rawValue, size: 14)
    contentsLabel.text = matchingMember.wishText
    contentsLabel.textColor = .idorm_gray_400
    contentsLabel.numberOfLines = 0
    contentsLabel.textAlignment = .left
    self.contentsLabel = contentsLabel
  }
  
  private func setupStyles() {
    layer.cornerRadius = 6
    backgroundColor = .white
  }
  
  private func setupLayout() {
    addSubview(contentsLabel)
  }
  
  private func setupConstraints() {
    contentsLabel.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(10)
    }
  }
}
