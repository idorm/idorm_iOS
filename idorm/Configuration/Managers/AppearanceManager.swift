import UIKit

final class AppearanceManager {
  static func navigationAppearance(from color: UIColor, shadow: Bool) -> UINavigationBarAppearance {
    let appearance = UINavigationBarAppearance()
    let backButtonAppearance = UIBarButtonItemAppearance()
    
    let backButton = UIImage(named: "BackButton")?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -12, bottom: -5, right: 0))
    backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear, .font: UIFont.systemFont(ofSize: 0)]
    appearance.setBackIndicatorImage(backButton, transitionMaskImage: backButton)
    appearance.backButtonAppearance = backButtonAppearance
    appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
    appearance.backgroundColor?.withAlphaComponent(0.95)
    appearance.backgroundColor = color
    
    if shadow {
      appearance.shadowColor = .black
    } else {
      appearance.shadowColor = nil
    }
    
    return appearance
  }
  
  static func tabbarAppearance(from color: UIColor) -> UITabBarAppearance {
    let appearance = UITabBarAppearance()
    appearance.backgroundColor = color
    appearance.shadowImage = UIImage()
    appearance.shadowColor = nil
    
    return appearance
  }
}
