//
//  DetailPhotoCell.swift
//  idorm
//
//  Created by 김응철 on 2023/02/18.
//

import UIKit

import SnapKit
import Kingfisher

final class DetailPhotoCell: UICollectionViewCell {
  
  // MARK: - UI COMPONENTS
  
  let mainImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.kf.indicatorType = .activity
    
    return iv
  }()
  
  // MARK: - PROPERTIES
  
  static let identifier = "DetailPhotoCell"
  
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
  /// 명시적으로 호출되어야 합니다.
  func injectImage(_ url: String) {
    self.mainImageView.kf.setImage(with: URL(string: url))
  }
  
  func setupStyles() {
    self.contentView.backgroundColor = .black
  }
  
  func setupLayouts() {
    self.contentView.addSubview(self.mainImageView)
  }
  
  func setupConstraints() {
    self.mainImageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
