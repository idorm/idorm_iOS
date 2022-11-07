import UIKit

import SnapKit
import Then

final class TopProfileView: UIView {
  
  // MARK: - Properties
  
  let nicknameLabel = UILabel().then {
    $0.text = "닉네임닉네임닉네임"
    $0.textColor = .idorm_gray_100
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14)
  }
  
  let profileImageView = UIImageView(image: UIImage(named: "myProfileImage(MyPage)"))
  
  // MARK: - LifeCycle
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    setupStyles()
    setupLayout()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  // MARK: - Setup
  
  private func setupStyles() {
    backgroundColor = .idorm_blue
    layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)
    layer.cornerRadius = 24
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 5)
    layer.shadowOpacity = 0.1
  }
  
  private func setupLayout() {
    [profileImageView, nicknameLabel]
      .forEach { addSubview($0) }
  }
  
  private func setupConstraints() {
    profileImageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(16)
    }
    
    nicknameLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(profileImageView.snp.bottom).offset(8)
    }
  }
}
