//
//  OnboardingUtilities.swift
//  idorm
//
//  Created by 김응철 on 2022/07/23.
//

import UIKit
import SnapKit

enum OnboardingVerifyType: String {
  case dorm
  case gender
  case period
  case wakeup
  case cleanup
  case shower
  case age
}

enum OnboardingOptionalType {
  case essential
  case optional
  case free
}

class OnboardingUtilities {
  static func getBasicButton(title: String) -> UIButton {
    var config = UIButton.Configuration.filled()
    var container = AttributeContainer()
    container.font = UIFont.init(name: Font.medium.rawValue, size: 14)
    container.foregroundColor = UIColor.grey_custom
    config.attributedTitle = AttributedString(title, attributes: container)
    config.baseBackgroundColor = .white
    config.cornerStyle = .capsule
    config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 18, bottom: 6, trailing: 18)
    config.background.strokeColor = .bluegrey
    config.background.strokeWidth = 1
    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = getButtonUpdateHandler()
    
    return button
  }
  
  static func getBasicLabel(text: String) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = .init(name: Font.medium.rawValue, size: 16)
    label.textColor = .black
    
    return label
  }
  
  static func getSeparatorLine() -> UIView {
    let view = UIView()
    view.backgroundColor = .blue_white
    
    return view
  }
  
  static func getButtonUpdateHandler() -> UIButton.ConfigurationUpdateHandler {
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .selected:
        button.configuration?.baseBackgroundColor = .mainColor
        button.configuration?.attributedTitle?.foregroundColor = UIColor.white
        button.configuration?.background.strokeWidth = 0
      default:
        button.configuration?.baseBackgroundColor = .white
        button.configuration?.attributedTitle?.foregroundColor = UIColor.grey_custom
        button.configuration?.background.strokeWidth = 1
      }
    }
    
    return handler
  }
}
