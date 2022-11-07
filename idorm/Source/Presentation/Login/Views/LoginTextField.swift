import UIKit

final class LoginTextField: UITextField {
  // MARK: - Properties
  
  // MARK: - Init
  init(_ placeholder: String) {
    super.init(frame: .zero)
    setupTextField(placeholder)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - LifeCycle
  override func layoutSubviews() {
    super.layoutSubviews()
    
    
  }
  
  // MARK: - Setup
  private func setupTextField(_ placeholder: String) {
    self.attributedPlaceholder = NSAttributedString(
      string: placeholder,
      attributes: [
        .foregroundColor: UIColor.idorm_gray_300,
        .font: UIFont.init(name: MyFonts.medium.rawValue, size: 14) ?? 0
      ]
    )
    self.textColor = .idorm_gray_300
    self.backgroundColor = .idorm_gray_100
    self.font = .init(name: MyFonts.medium.rawValue, size: 14)
    self.layer.cornerRadius = 14.0
    self.addLeftPadding(16)
  }
}
