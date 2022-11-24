import UIKit

// MARK: - ConfirmPassword VC

final class RegisterUtilities {
  /// ConfirmPasswordVC의 InfoLabel을 반환합니다.
  static func infoLabel(text: String) -> UILabel {
    let label = UILabel()
    label.textColor = .black
    label.font = .init(name: MyFonts.medium.rawValue, size: 14)
    
    return label
  }
  
  /// ConfirmPasswordVC의 descriptionLabel을 반환합니다.
  static func descriptionLabel(text: String) -> UILabel {
    let label = UILabel()
    label.textColor = .idorm_gray_400
    label.font = .init(name: MyFonts.medium.rawValue, size: 12)
    
    return label
  }
}
