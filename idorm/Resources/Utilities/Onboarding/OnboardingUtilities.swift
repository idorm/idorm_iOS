//
//  OnboardingUtilities.swift
//  idorm
//
//  Created by 김응철 on 2022/07/23.
//

import UIKit
import SnapKit

enum OnboardingListType: Int, CaseIterable {
  case wakeup
  case cleanup
  case shower
  case mbti
  case chatLink
  case wishText
  
  var query: String {
    switch self {
    case .wakeup: return "기상시간을 알려주세요."
    case .cleanup: return "정리정돈은 얼마나 하시나요?"
    case .shower: return "샤워는 주로 언제/몇 분 동안 하시나요?"
    case .mbti: return "MBTI를 알려주세요."
    case .chatLink: return "룸메와 연락을 위한 개인 오픈채팅 링크를 알려주세요."
    case .wishText: return "미래의 룸메에게 하고 싶은 말은?"
    }
  }
}

enum OnboardingHeaderListType: String, CaseIterable {
  case dorm
  case gender
  case period
  case snore
  case grinding
  case smoke
  case allowedFood
  case earphone
  case age
  
  var query: String {
    switch self {
    case .dorm: return "기숙사"
    case .gender: return "성별"
    case .period: return "입사 기간"
    case .snore, .grinding, .smoke, .allowedFood, .earphone: return "내 습관"
    case .age: return "나이"
    }
  }
}

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
