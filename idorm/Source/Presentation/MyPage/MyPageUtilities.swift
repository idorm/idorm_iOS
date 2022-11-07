import UIKit

// MARK: - MyPageVC

class MyPageUtilities {
  static func createMatchingButton(imageName: String, title: String) -> UIButton {
    var config = UIButton.Configuration.filled()
    config.image = UIImage(named: imageName)
    config.imagePlacement = .top
    config.imagePadding = 8
    var container = AttributeContainer()
    container.font = .init(name: MyFonts.regular.rawValue, size: 12)
    container.foregroundColor = UIColor.black
    config.attributedTitle = AttributedString(title, attributes: container)
    config.titleAlignment = .center
    config.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 18, bottom: 18, trailing: 18)
    config.baseBackgroundColor = .idorm_gray_100
    let button = UIButton(configuration: config)
    button.layer.cornerRadius = 12
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .highlighted:
        button.configuration?.baseBackgroundColor = .idorm_gray_200
      default:
        button.configuration?.baseBackgroundColor = .idorm_gray_100
      }
    }
    button.configurationUpdateHandler = handler
    
    return button
  }
  
  static func createCommunityButton(imageName: String, title: String) -> UIButton {
    var config = UIButton.Configuration.filled()
    config.image = UIImage(named: imageName)
    config.imagePlacement = .top
    config.imagePadding = 8
    var container = AttributeContainer()
    container.font = .init(name: MyFonts.regular.rawValue, size: 12)
    container.foregroundColor = UIColor.black
    config.attributedTitle = AttributedString(title, attributes: container)
    config.titleAlignment = .center
    config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 6, bottom: 12, trailing: 6)
    config.baseBackgroundColor = .idorm_gray_100
    let button = UIButton(configuration: config)
    button.layer.cornerRadius = 12
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .highlighted:
        button.configuration?.baseBackgroundColor = .idorm_gray_200
      default:
        button.configuration?.baseBackgroundColor = .idorm_gray_100
      }
    }
    button.configurationUpdateHandler = handler
    
    return button
  }
  
  static func createTitleLabel(title: String) -> UILabel {
    let label = UILabel()
    label.text = title
    label.font = .init(name: MyFonts.medium.rawValue, size: 16)
    label.textColor = .black
    
    return label
  }
}

// MARK: - ManageMyInfoVC

extension MyPageUtilities {
  static func separatorLine() -> UIView {
    let line = UIView()
    line.backgroundColor = .idorm_gray_100
    return line
  }
}
