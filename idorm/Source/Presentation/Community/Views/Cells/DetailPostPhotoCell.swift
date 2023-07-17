//
//  PostDetailPhotoCell.swift
//  idorm
//
//  Created by 김응철 on 2023/02/13.
//

import UIKit

import SnapKit
import Kingfisher

final class DetailPostPhotoCell: UICollectionViewCell {
  
  // MARK: - PROPERTIES
  
  private let mainImageView: UIImageView = {
    let iv = UIImageView()
    iv.layer.cornerRadius = 8
    iv.layer.masksToBounds = true
    iv.contentMode = .scaleAspectFill
    
    return iv
  }()
  
  // MARK: - INITIALIZER
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupStyles()
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - SETUP

extension DetailPostPhotoCell: BaseView {
  func injectData(_ imageURL: String) {
    self.mainImageView.kf.setImage(with: URL(string: imageURL)!)
  }
  
  func setupStyles() {
    self.backgroundColor = .white
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
