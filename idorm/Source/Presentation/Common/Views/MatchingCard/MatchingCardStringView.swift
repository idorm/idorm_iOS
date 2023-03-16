import UIKit

import SnapKit
import Then

final class MatchingCardStringView: UIView {
  
  // MARK: - Properties
  
  private var queryLabel: UILabel!
  private var contentsLabel: UILabel!
  
  private let member: MatchingResponseModel.Member
  private let type: MatchingCardStringList
  
  // MARK: - LifeCycle
  
  init(_ from: MatchingResponseModel.Member, type: MatchingCardStringList) {
    self.member = from
    self.type = type
    super.init(frame: .zero)
    setupQueryLabel()
    setupContentsLabel()
    setupStyles()
    setupLayout()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupQueryLabel() {
    let queryLabel = UILabel()
    queryLabel.text = type.title
    queryLabel.textColor = .black
    queryLabel.font = .init(name: IdormFont_deprecated.bold.rawValue, size: 14)
    queryLabel.setContentHuggingPriority(.init(251), for: .horizontal)
    queryLabel.setContentCompressionResistancePriority(.init(751), for: .horizontal)
    self.queryLabel = queryLabel
  }
  
  private func setupContentsLabel() {
    let contentsLabel = UILabel()
    contentsLabel.font = .init(name: IdormFont_deprecated.medium.rawValue, size: 14)
    contentsLabel.textColor = .idorm_gray_400
    switch type {
    case .wakeUp:
      contentsLabel.text = member.wakeUpTime
    case .cleanUp:
      contentsLabel.text = member.cleanUpStatus
    case .showerTime:
      contentsLabel.text = member.showerTime
    case .mbti:
      contentsLabel.text = member.mbti
    }
    self.contentsLabel = contentsLabel
  }

  private func setupStyles() {
    layer.cornerRadius = 12
    backgroundColor = .white
    layer.shadowOffset = CGSize(width: 0, height: 5)
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.2
  }
  
  private func setupLayout() {
    [queryLabel, contentsLabel]
      .forEach { addSubview($0) }
  }
  
  private func setupConstraints() {
    queryLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(10)
      make.centerY.equalToSuperview()
    }
    
    switch type {
    case .mbti:
      contentsLabel.snp.makeConstraints { make in
        make.leading.equalTo(queryLabel.snp.trailing).offset(24)
        make.trailing.equalToSuperview().inset(10)
        make.centerY.equalToSuperview()
      }
    default:
      contentsLabel.snp.makeConstraints { make in
        make.leading.equalTo(queryLabel.snp.trailing).offset(6)
        make.trailing.equalToSuperview().inset(10)
        make.centerY.equalToSuperview()
      }
    }
  }
}
