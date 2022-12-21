import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class ManageMyInfoView: UIView {
  
  // MARK: - Properties
  
  private let titleLabel = UILabel().then {
    $0.font = .init(name: MyFonts.regular.rawValue, size: 16)
    $0.textColor = .idorm_gray_400
  }
  
  let descriptionLabel = UILabel().then {
    $0.font = .init(name: MyFonts.regular.rawValue, size: 16)
    $0.textColor = .idorm_gray_300
  }
  
  private let arrowImageView = UIImageView(image: #imageLiteral(resourceName: "rightArrow(Mypage)"))
  
  private let type: MyPageEnumerations.ManageMyInfoView
  
  // MARK: - LifeCycle
  
  init(type: MyPageEnumerations.ManageMyInfoView, title: String) {
    self.type = type
    super.init(frame: .zero)
    titleLabel.text = title
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
    
    switch type {
    case .onlyArrow: break
    case let .onlyDescription(description), let .both(description: description):
      descriptionLabel.text = description
    }
  }
  
  private func setupLayout() {
    addSubview(titleLabel)
    switch type {
    case .onlyArrow:
      addSubview(arrowImageView)
    case .onlyDescription(_):
      addSubview(descriptionLabel)
    case .both(_):
      addSubview(arrowImageView)
      addSubview(descriptionLabel)
    }
  }
  
  private func setupConstraints() {
    titleLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().inset(24)
    }
    
    switch type {
    case .onlyArrow:
      arrowImageView.snp.makeConstraints { make in
        make.centerY.equalToSuperview()
        make.trailing.equalToSuperview().inset(24)
      }
    case .onlyDescription:
      descriptionLabel.snp.makeConstraints { make in
        make.centerY.equalToSuperview()
        make.trailing.equalToSuperview().inset(24)
      }
    case .both:
      arrowImageView.snp.makeConstraints { make in
        make.centerY.equalToSuperview()
        make.trailing.equalToSuperview().inset(24)
      }
      
      descriptionLabel.snp.makeConstraints { make in
        make.centerY.equalToSuperview()
        make.trailing.equalTo(arrowImageView.snp.leading).offset(-12)
      }
    }
  }
}
