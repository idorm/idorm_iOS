import UIKit

import SnapKit
import Then

final class MyRoommateHeaderView: UIView {
  
  // MARK: - Properties
  
  private lazy var lastestLabel = label("최신순")
  
  private lazy var pastLabel = label("과거순")
  
  lazy var lastestButton = button()
  lazy var pastButton = button()
  
  // MARK: - LifeCycle
  
  override init(frame: CGRect) {
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
    backgroundColor = .clear
  }
  
  private func setupLayout() {
    [lastestLabel, lastestButton, pastLabel, pastButton]
      .forEach { addSubview($0) }
  }
  
  private func setupConstraints() {
    lastestLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.centerY.equalToSuperview()
    }
    
    lastestButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalTo(lastestLabel.snp.trailing).offset(4)
    }
    
    pastLabel.snp.makeConstraints { make in
      make.leading.equalTo(lastestButton.snp.trailing).offset(12)
      make.centerY.equalToSuperview()
    }
    
    pastButton.snp.makeConstraints { make in
      make.leading.equalTo(pastLabel.snp.trailing).offset(4)
      make.centerY.equalToSuperview()
    }
  }
}

// MARK: - Helpers

extension MyRoommateHeaderView {
  private func label(_ title: String) -> UILabel {
    let label = UILabel()
    label.textColor = .black
    label.text = title
    label.font = .init(name: MyFonts.regular.rawValue, size: 14)
    
    return label
  }
  
  private func button() -> UIButton {
    let button = UIButton()
    var config = UIButton.Configuration.plain()
    config.image = #imageLiteral(resourceName: "myPostButton")
    
    button.configurationUpdateHandler = { button in
      switch button.state {
      case .selected:
        config.image = #imageLiteral(resourceName: "myPostButton_Hover")
      default:
        config.image = #imageLiteral(resourceName: "myPostButton")
      }
    }
    button.configuration = config
    
    return button
  }
}
