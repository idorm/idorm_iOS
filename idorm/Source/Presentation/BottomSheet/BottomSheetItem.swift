//
//  BottomSheetItem.swift
//  idorm
//
//  Created by 김응철 on 7/24/23.
//

import UIKit

enum BottomSheetItem {
  case normal(title: String, image: UIImage? = nil)
  
  /// 각 케이스에 맞는 버튼을 추출합니다.
  var button: UIButton {
    switch self {
    case let .normal(title, image):
      var config = UIButton.Configuration.filled()
      var container = AttributeContainer()
      container.font = .iDormFont(.medium, size: 20)
      container.foregroundColor = UIColor.black
      config.attributedTitle = AttributedString(title, attributes: container)
      config.image = image
      config.imagePlacement = .leading
      config.imagePadding = 8
      config.baseBackgroundColor = .white
      let button = UIButton(configuration: config)
      button.configurationUpdateHandler = self.getButtonUpdateHandler()
      button.contentHorizontalAlignment = .leading
      return button
    }
  }
}

extension BottomSheetItem {
  func getButtonUpdateHandler() -> UIButton.ConfigurationUpdateHandler {
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .highlighted:
        button.configuration?.baseBackgroundColor = .iDormColor(.iDormGray100)
      default:
        button.configuration?.baseBackgroundColor = .white
      }
    }
    return handler
  }}
