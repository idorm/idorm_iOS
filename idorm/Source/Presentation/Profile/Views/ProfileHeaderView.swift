//
//  ProfileHeaderView.swift
//  idorm
//
//  Created by 김응철 on 9/29/23.
//

import UIKit

import SnapKit

final class ProfileHeaderView: BaseReusableView {
  
  // MARK: - UI Components
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.medium, size: 16.0)
    return label
  }()
  
  // MARK: - Setup
  
  override func setupLayouts() {
    self.addSubview(self.titleLabel)
  }
  
  override func setupConstraints() {
    self.titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(16.0)
      make.leading.equalToSuperview()
    }
  }
  
  // MARK: - Configure
  
  func configure(with section: ProfileSection) {
    self.titleLabel.text = section.headerTitle
  }
}
