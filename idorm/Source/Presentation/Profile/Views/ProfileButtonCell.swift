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
  
  private lazy var button: iDormButton = {
    let button = iDormButton()
    button.imagePadding = 8.0
    button.imagePlacement = .top
    button.baseBackgroundColor = .iDormColor(.iDormGray100)
    button.baseForegroundColor = .black
    button.font = .iDormFont(.regular, size: 12.0)
    button.cornerRadius = 12.0
    button.shadowOffset = CGSize(width: .zero, height: 2.0)
    button.shadowOpacity = 0.11
    button.shadowRadius = 2.0
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      guard let button = button as? iDormButton else { return }
      switch button.state {
      case .highlighted:
        button.baseBackgroundColor = .iDormColor(.iDormGray200)
      default:
        button.baseBackgroundColor = .iDormColor(.iDormGray100)
      }
    }
    button.configurationUpdateHandler = handler
    return button
  }()

  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.addSubview(self.button)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.button.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  // MARK: - Configure
  
  func configure(with item: ProfileSectionItem) {
    self.button.image = item.image
    self.button.title = item.title
  }
}
