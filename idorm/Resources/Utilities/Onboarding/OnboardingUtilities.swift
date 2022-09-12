//
//  OnboardingUtilities.swift
//  idorm
//
//  Created by 김응철 on 2022/07/23.
//

import UIKit
import SnapKit

class OnboardingUtilities {
  static func getBasicButton(title: String) -> UIButton {
    var config = UIButton.Configuration.filled()
    var container = AttributeContainer()
    container.font = UIFont.init(name: Font.medium.rawValue, size: 14)
    container.foregroundColor = UIColor.idorm_gray_300
    config.attributedTitle = AttributedString(title, attributes: container)
    config.baseBackgroundColor = .white
    config.cornerStyle = .capsule
    config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 18, bottom: 6, trailing: 18)
    config.background.strokeColor = .idorm_gray_200
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
    view.backgroundColor = .idorm_gray_100
    
    return view
  }
  
  static func getButtonUpdateHandler() -> UIButton.ConfigurationUpdateHandler {
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
