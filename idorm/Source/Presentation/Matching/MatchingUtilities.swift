import UIKit

import Then
import RangeSeekSlider

final class MatchingUtilities {
  static func basicButton(title: String) -> UIButton {
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
    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = getButtonUpdateHandler()
    
    return button
  }
  
  static func titleLabel(text: String) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = .init(name: MyFonts.medium.rawValue, size: 16)
    label.textColor = .black
    
    return label
  }

  static func separatorLine() -> UIView {
    let view = UIView()
    view.backgroundColor = .idorm_gray_100
    
    return view
  }
  
  static func descriptionLabel(_ title: String) -> UILabel {
    let label = UILabel()
    label.text = title
    label.textColor = .idorm_gray_300
    label.font = .init(name: MyFonts.medium.rawValue, size: 12.0)
    
    return label
  }
  
  static func slider() -> RangeSeekSlider {
    return RangeSeekSlider().then {
      $0.backgroundColor = .white
      $0.colorBetweenHandles = .idorm_blue
      $0.tintColor = .idorm_gray_100
      $0.labelPadding = 6
      $0.minLabelColor = .black
      $0.maxLabelColor = .black
      $0.minLabelFont = .init(name: MyFonts.medium.rawValue, size: 12)!
      $0.maxLabelFont = .init(name: MyFonts.medium.rawValue, size: 12)!
      $0.minValue = 20
      $0.maxValue = 40
      $0.selectedMaxValue = 30
      $0.selectedMinValue = 20
      $0.lineHeight = 11
      $0.handleImage = UIImage(named: "thumb(Matching)")
      $0.minDistance = 1
      $0.enableStep = true
      $0.selectedHandleDiameterMultiplier = 1.0
    }
  }
}

extension MatchingUtilities {
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
