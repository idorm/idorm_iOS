import UIKit

final class UIFactory {
  static func label(text: String, color: UIColor, font: UIFont?) -> UILabel {
    let label = UILabel()
    label.text = text
    label.textColor = color
    label.font = font
    return label
  }
}
