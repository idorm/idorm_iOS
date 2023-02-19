//
//  DetailPhotoCell.swift
//  idorm
//
//  Created by 김응철 on 2023/02/18.
//

import UIKit

import SnapKit

final class DetailPhotoCell: UICollectionViewCell {
  
  // MARK: - UI COMPONENTS
  
  private let photoView: UIImageView = {
    let iv = UIImageView()
    
    return iv
  }()
  
  // MARK: - INITIALIZER
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - SETUP

extension DetailPhotoCell: BaseView {
  func setupStyles() {
    self.contentView.backgroundColor = .black
  }
  
  func setupLayouts() {
    self.contentView.addSubview(self.photoView)
  }
  
  func setupConstraints() {
    self.photoView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
}
