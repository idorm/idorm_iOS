import UIKit

final class RegisterTextField: UITextField {
  
  // MARK: - Init
  
  init(_ title: String) {
    super.init(frame: .zero)
    setupTextField(title)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupTextField(_ title: String) {
    self.attributedPlaceholder = NSAttributedString(
      string: title,
      attributes: [
        .foregroundColor: UIColor.idorm_gray_300,
        .font: UIFont.init(name: MyFonts.medium.rawValue, size: 14) ?? 0
      ]
    )
    font = .init(name: MyFonts.medium.rawValue, size: 14)
    textColor = .idorm_gray_300
    addLeftPadding(14)
    layer.borderWidth = 1
    layer.borderColor = UIColor.idorm_gray_300.cgColor
    layer.cornerRadius = 10
    backgroundColor = .white
    
    self.frame.size.height = 50
  }
}
