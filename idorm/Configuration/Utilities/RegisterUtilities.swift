import UIKit

final class RegisterUtilities {
  /// ConfirmPasswordVC의 InfoLabel을 반환합니다.
  static func infoLabel(text: String) -> UILabel {
    let label = UILabel()
    label.text = text
    label.textColor = .black
    label.font = .init(name: MyFonts.medium.rawValue, size: 14.0)
    return label
  }
  
  /// ConfirmPasswordVC의 descriptionLabel을 반환합니다.
  static func descriptionLabel(text: String) -> UILabel {
    let label = UILabel()
    label.font = .init(name: MyFonts.medium.rawValue, size: 12.0)
    label.textColor = .idorm_gray_400
    label.text = text
    
    return label
  }
}
