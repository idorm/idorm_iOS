//
//  OnboardingButton.swift
//  idorm
//
//  Created by 김응철 on 2023/01/27.
//

import UIKit

final class OnboardingButton: UIButton {
  
  // MARK: - Initalizer
  
  init(_ title: String) {
    super.init(frame: .zero)
    setupConfiguration(title)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupConfiguration(_ title: String) {
    var config = UIButton.Configuration.filled()
    var container = AttributeContainer()
    container.font = UIFont.init(name: MyFonts.medium.rawValue, size: 14)
    container.foregroundColor = UIColor.idorm_gray_300
    config.attributedTitle = AttributedString(title, attributes: container)
    config.baseBackgroundColor = .white
    config.cornerStyle = .capsule
    config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 18, bottom: 6, trailing: 18)
    config.background.strokeColor = .idorm_gray_200
    config.background.strokeWidth = 1
    
    self.configuration = config
  }
}

private extension OnboardingButton {
  func getButtonUpdateHandler() -> UIButton.ConfigurationUpdateHandler {
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .selected:
        button.configuration?.baseBackgroundColor = .idorm_blue
        button.configuration?.attributedTitle?.foregroundColor = UIColor.white
        button.configuration?.background.strokeWidth = 0
      default:
        button.configuration?.baseBackgroundColor = .white
        button.configuration?.attributedTitle?.foregroundColor = UIColor.idorm_gray_300
        button.configuration?.background.strokeWidth = 1
      }
    }
    
    return handler
  }
}
