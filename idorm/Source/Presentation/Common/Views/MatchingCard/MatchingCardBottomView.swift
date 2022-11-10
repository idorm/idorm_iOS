import UIKit

import SnapKit
import Then

final class MatchingCardBottomView: UIView {
  
  // MARK: - Properties
  
  private let humanImageView = UIImageView(image: UIImage(named: "Human"))
  
  let optionButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    config.image = UIImage(named: "matchingCardOption")
    $0.configuration = config
  }
  
  private lazy var genderLabel = UILabel().then {
    $0.text = matchingInfo.gender == .male ? "남자," : "여자,"
    $0.textColor = .idorm_gray_400
    $0.font = .init(name: MyFonts.bold.rawValue, size: 12)
  }
  
  private lazy var ageLabel = UILabel().then {
    $0.text = String(matchingInfo.age) + " 세"
    $0.textColor = .idorm_gray_400
    $0.font = .init(name: MyFonts.bold.rawValue, size: 12)
  }
  
  private lazy var mbtiLabel = UILabel().then {
    $0.text = matchingInfo.mbti
    $0.textColor = .idorm_gray_300
    $0.font = .init(name: MyFonts.bold.rawValue, size: 12)
  }
  
  private let matchingInfo: MatchingMember
  
  // MARK: - LifeCycle
  
  init(_ matchingInfo: MatchingMember) {
    self.matchingInfo = matchingInfo
    super.init(frame: .zero)
    setupStyles()
    setupLayout()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupStyles() {
    backgroundColor = .white
    layer.borderColor = UIColor.idorm_gray_200.cgColor
    layer.borderWidth = 1
  }
  
  private func setupLayout() {
    [humanImageView, genderLabel, ageLabel, mbtiLabel, optionButton]
      .forEach { addSubview($0) }
  }
  
  private func setupConstraints() {
    humanImageView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().inset(12)
    }
    
    genderLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalTo(humanImageView.snp.trailing).offset(8)
    }
    
    ageLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalTo(genderLabel.snp.trailing).offset(4)
    }
    
    optionButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(12)
      make.centerY.equalToSuperview()
    }
    
    mbtiLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalTo(optionButton.snp.leading).offset(-8)
    }
  }
}
