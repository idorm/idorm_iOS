//
//  BottomSheetUtils.swift
//  idorm
//
//  Created by 김응철 on 2023/02/14.
//

import UIKit

final class BottomSheetUtils {
  /// 신고하기 버튼을 반환합니다.
  static func reportButton() -> UIButton {
    var config = UIButton.Configuration.filled()
    var titleContainer = AttributeContainer()
    titleContainer.font = .idormFont(.medium, size: 20)
    titleContainer.foregroundColor = UIColor.black
    var subtitleContainer = AttributeContainer()
    subtitleContainer.font = .idormFont(.medium, size: 14)
    subtitleContainer.foregroundColor = UIColor.idorm_gray_400
    config.attributedTitle = AttributedString("신고하기", attributes: titleContainer)
    config.attributedSubtitle = AttributedString("idorm의 커뮤니티 가이드라인에 위배되는 댓글", attributes: subtitleContainer)
    config.baseBackgroundColor = .white
    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = BottomSheetUtils.getButtonUpdateHandler()
    button.contentHorizontalAlignment = .leading
    
    return button
  }
  
  /// 일반 버튼을 반환합니다.
  static func basicButton(_ title: String, imageName: String) -> UIButton {
    var config = UIButton.Configuration.filled()
    var container = AttributeContainer()
    container.font = .idormFont(.medium, size: 20)
    container.foregroundColor = UIColor.black
    config.attributedTitle = AttributedString(title, attributes: container)
    config.image = UIImage(named: imageName)
    config.imagePlacement = .leading
    config.imagePadding = 8
    config.baseBackgroundColor = .white
    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = BottomSheetUtils.getButtonUpdateHandler()
    button.contentHorizontalAlignment = .leading
    
    return button
  }

  /// 기숙사 별 버튼을 반환합니다.
  static func dormNumberButton(_ title: String) -> UIButton {
    var config = UIButton.Configuration.filled()
    var container = AttributeContainer()
    container.font = .idormFont(.bold, size: 20)
    container.foregroundColor = UIColor.black
    config.attributedTitle = AttributedString(title, attributes: container)
    let button = UIButton(configuration: config)
    button.contentHorizontalAlignment = .leading
    button.configurationUpdateHandler = BottomSheetUtils.getButtonUpdateHandler()
    return button
  }
}

extension BottomSheetUtils {
  static func getButtonUpdateHandler() -> UIButton.ConfigurationUpdateHandler {
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .highlighted:
        button.configuration?.baseBackgroundColor = .idorm_gray_100
      default:
        button.configuration?.baseBackgroundColor = .white
      }
    }
    return handler
  }

  static func button(_ imageName: String) -> UIButton {
    let button = UIButton()
    button.setImage(UIImage(named: imageName), for: .normal)

    return button
  }
}
