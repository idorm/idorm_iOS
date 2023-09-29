import UIKit

import SnapKit
import Then

final class TopProfileView: UIView {
  
  // MARK: - Properties
  
  let gearBtn: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "gear"), for: .normal)
    
    return btn
  }()
  
  let nicknameLabel: UILabel = {
    let lb = UILabel()
    lb.textColor = .idorm_gray_100
    lb.font = .init(name: IdormFont_deprecated.medium.rawValue, size: 14)
    
    return lb
  }()
  
  let profileImageView: UIImageView = {
    let iv = UIImageView(image: #imageLiteral(resourceName: "sqaure_human"))
    iv.layer.cornerRadius = 12
    iv.layer.masksToBounds = true
    return iv
  }()
  
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
    [
      profileImageView,
      nicknameLabel,
      gearBtn
    ].forEach { addSubview($0) }
  }
  
  private func setupConstraints() {
    profileImageView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.width.height.equalTo(68)
      make.bottom.equalTo(nicknameLabel.snp.top).offset(-8)
    }
    
    nicknameLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview().inset(24)
    }
    
    gearBtn.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(16)
      make.trailing.equalToSuperview().inset(24)
    }
  }
}
