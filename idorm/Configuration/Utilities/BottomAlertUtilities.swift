import UIKit

final class BottomAlertUtilities {
  /// 신고하기 버튼을 반환합니다.
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
  
  /// 일반 버튼을 반환합니다.
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

  /// 기숙사 별 버튼을 반환합니다.
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
