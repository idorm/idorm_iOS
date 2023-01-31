import UIKit

import SnapKit
import Then

final class MatchingCardBoolView: UIView {
  
  // MARK: - Properties
  
  private var queryLabel: UILabel!
  private var validLabel: UILabel!
  private var stackView: UIStackView!
  
  private let member: MatchingResponseModel.Member
  private let type: MatchingCardBoolList
  
  // MARK: - LifeCycle
  
  init(_ from: MatchingResponseModel.Member, type: MatchingCardBoolList) {
    self.member = from
    self.type = type
    super.init(frame: .zero)
    setupQueryLabel()
    setupValidLabel()
    setupStackView()
    setupStyles()
    setupLayout()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupQueryLabel() {
    let label = UILabel()
    label.text = type.queryString
    label.textColor = .black
    label.font = .init(name: MyFonts.medium.rawValue, size: 14)
    self.queryLabel = label
  }
  
  private func setupValidLabel() {
    let label = UILabel()
    switch type {
    case .snoring:
      label.textColor = member.isSnoring ? UIColor.red : UIColor.idorm_blue
      label.text = member.isSnoring ? "있음" : "없음"
    case .grinding:
      label.textColor = member.isGrinding ? UIColor.red : UIColor.idorm_blue
      label.text = member.isGrinding ? "있음" : "없음"
    case .smoking:
      label.textColor = member.isSmoking ? UIColor.red : UIColor.idorm_blue
      label.text = member.isSmoking ? "함" : "안함"
    case .food:
      label.textColor = member.isAllowedFood ? UIColor.idorm_blue : UIColor.red
      label.text = member.isAllowedFood ? "가능" : "불가능"
    case .earphone:
      label.textColor = member.isWearEarphones ? UIColor.idorm_blue : UIColor.red
      label.text = member.isWearEarphones ? "가능" : "불가능"
    }
    label.font = .init(name: MyFonts.bold.rawValue, size: 14)
    self.validLabel = label
  }
  
  private func setupStackView() {
    let stack = UIStackView(arrangedSubviews: [queryLabel, validLabel])
    stack.axis = .horizontal
    stack.alignment = .center
    stack.spacing = 4
    self.stackView = stack
  }
  
  private func setupStyles() {
    backgroundColor = .white
    layer.cornerRadius = 15
    layer.shadowOffset = CGSize(width: 0, height: 5)
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.2
  }
  
  private func setupLayout() {
    addSubview(stackView)
  }
  
  private func setupConstraints() {
    stackView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(10)
      make.centerY.equalToSuperview()
    }
  }
}
