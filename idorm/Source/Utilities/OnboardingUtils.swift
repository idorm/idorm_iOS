import UIKit

import SnapKit

final class OnboardingUtilities {
  
  static func infoLabel(_ title: String, isEssential: Bool) -> UILabel {
    let label = UILabel()
    label.text = title
    label.textColor = .idorm_gray_400
    label.font = .init(name: MyFonts.medium.rawValue, size: 14)
    
    if isEssential {
      let essentialLabel = UILabel()
      essentialLabel.text = "(필수)"
      essentialLabel.textColor = .idorm_blue
      essentialLabel.font = .init(name: MyFonts.medium.rawValue, size: 14)
      
      label.addSubview(essentialLabel)
      essentialLabel.snp.makeConstraints { make in
        make.centerY.equalToSuperview()
        make.leading.equalTo(label.snp.trailing).offset(8)
      }
    }
    
    return label
  }
}
