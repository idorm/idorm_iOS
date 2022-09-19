//
//  CommunityUtilities.swift
//  idorm
//
//  Created by 김응철 on 2022/07/21.
//

import UIKit

enum PostType: Int, CaseIterable {
  case popular
  case post
}

enum CommunityAlertType: Int {
  case myComment = 171
  case someoneComment = 129
  case myPost = 250
  case someonePost = 166
  case selectDorm = 182
}

class CommunityUtilities {
  static func getSeparatorLine() -> UIView {
    let view = UIView()
    view.backgroundColor = .idorm_gray_200
    
    return view
  }
  
  static func getCountLabel() -> UILabel {
    let label = UILabel()
    label.text = "100"
    label.font = .init(name: MyFonts.medium.rawValue, size: 10)
    label.textColor = .idorm_gray_300
    
    return label
  }
  
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
  
  static func getReportButton() -> UIButton {
    var config = UIButton.Configuration.filled()
    var titleContainer = AttributeContainer()
    titleContainer.font = UIFont.init(name: MyFonts.medium.rawValue, size: 20)
    titleContainer.foregroundColor = UIColor.black
    var subtitleContainer = AttributeContainer()
    subtitleContainer.font = UIFont.init(name: MyFonts.medium.rawValue, size: 14)
    subtitleContainer.foregroundColor = UIColor.idorm_gray_400
    config.attributedTitle = AttributedString("신고하기", attributes: titleContainer)
    config.attributedSubtitle = AttributedString("idorm의 커뮤니티 가이드라인에 위배되는 댓글", attributes: subtitleContainer)
    config.baseBackgroundColor = .white
    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = CommunityUtilities.getButtonUpdateHandler()
    button.contentHorizontalAlignment = .leading
    
    return button
  }
  
  static func getBasicButton(title: String, imageName: String) -> UIButton {
    var config = UIButton.Configuration.filled()
    var container = AttributeContainer()
    container.font = UIFont.init(name: MyFonts.medium.rawValue, size: 20)
    container.foregroundColor = UIColor.black
    config.attributedTitle = AttributedString(title, attributes: container)
    config.image = UIImage(named: imageName)
    config.imagePlacement = .leading
    config.imagePadding = 8
    config.baseBackgroundColor = .white
    let button = UIButton(configuration: config)
    button.configurationUpdateHandler = CommunityUtilities.getButtonUpdateHandler()
    button.contentHorizontalAlignment = .leading
    
    return button
  }
  
  static func getDormNumberButton(title: String) -> UIButton {
    var config = UIButton.Configuration.filled()
    var container = AttributeContainer()
    container.font = UIFont.init(name: MyFonts.bold.rawValue, size: 20)
    container.foregroundColor = UIColor.black
    config.attributedTitle = AttributedString(title, attributes: container)
    let button = UIButton(configuration: config)
    button.contentHorizontalAlignment = .leading
    button.configurationUpdateHandler = CommunityUtilities.getButtonUpdateHandler()
    return button
  }
}
