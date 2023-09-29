//
//  ProfileButtonCell.swift
//  idorm
//
//  Created by 김응철 on 9/29/23.
//

import UIKit

import SnapKit

final class ProfileButtonCell: BaseCollectionViewCell {
  
  // MARK: - UI Components
  
  private let iconButton: iDormButton = {
    let button = iDormButton()
    button.cornerRadius = 26.0
    button.baseBackgroundColor = .white
    return button
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.regular, size: 12.0)
    label.textColor = .black
    return label
  }()
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.contentView.layer.cornerRadius = 12.0
    self.contentView.layer.shadowOpacity = 0.11
    self.contentView.layer.shadowRadius = 2.0
    self.contentView.layer.shadowOffset = CGSize(width: .zero, height: 2.0)
    self.contentView.backgroundColor = .iDormColor(.iDormGray100)
  }
  
  override func setupLayouts() {
    [
      self.iconButton,
      self.titleLabel
    ].forEach {
      self.contentView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.iconButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(12.0)
      make.size.equalTo(52.0)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.iconButton.snp.bottom).offset(8.0)
    }
  }
  
  // MARK: - Configure
  
  func configure(with item: ProfileSectionItem) {
    self.iconButton.image = item.icon
    self.titleLabel.text = item.title
  }
}
