//
//  ManagementMyInfoCell.swift
//  idorm
//
//  Created by 김응철 on 9/29/23.
//

import UIKit

import SnapKit

final class ManagementMyInfoCell: BaseCollectionViewCell {
  
  // MARK: - UI Components
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.regular, size: 16.0)
    label.textColor = .iDormColor(.iDormGray400)
    return label
  }()
  
  private let subtitleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .iDormColor(.iDormGray300)
    label.font = .iDormFont(.regular, size: 16.0)
    return label
  }()
  
  private let rightButton: UIButton = {
    let button = UIButton()
    button.setImage(.iDormIcon(.right), for: .normal)
    return button
  }()
  
  // MARK: - Properties
  
  private var subtitleTrailingInset: Constraint?
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.titleLabel,
      self.subtitleLabel,
      self.rightButton
    ].forEach {
      self.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.titleLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().inset(24.0)
    }
    
    self.subtitleLabel.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      self.subtitleTrailingInset = make.trailing.equalToSuperview().inset(24.0).constraint
    }
    
    self.rightButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(16.0)
    }
  }
  
  // MARK: - Configure
  
  func configure(with item: ManagementMyInfoSectionItem) {
    self.titleLabel.text = item.title
    self.rightButton.isHidden = item.isHiddenRightButton
    self.subtitleTrailingInset?.update(inset: item.subtitleTrailingInset)
    switch item {
    case .email(let text), .nickname(let text):
      self.subtitleLabel.text = text
    case .version:
      self.subtitleLabel.text = "version"
    default:
      self.subtitleLabel.text = ""
    }
  }
}
