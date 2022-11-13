import UIKit

final class RegisterUtilities {
  /// ConfirmPasswordVC의 InfoLabel을 반환합니다.
  static func infoLabel(text: String) -> UILabel {
    return UIFactory.label(
      text: text,
      color: .black,
      font: .init(name: MyFonts.medium.rawValue, size: 14)
    )
  }
  
  /// ConfirmPasswordVC의 descriptionLabel을 반환합니다.
  static func descriptionLabel(text: String) -> UILabel {
    return UIFactory.label(
      text: text,
      color: .idorm_gray_400,
      font: .init(name: MyFonts.medium.rawValue, size: 12)
    )
  }
}
