//
//  PostDetailPhotoCell.swift
//  idorm
//
//  Created by 김응철 on 2023/02/13.
//

import UIKit

import SnapKit
import Kingfisher

/// 게시글의 사진 `UICollectionViewCell`
final class CommunityPostPhotoCell: UICollectionViewCell {
  
  // MARK: - UI Components
  
  /// 게시글의 사진을 보여주는 `UIImageView`
  private let imageView: UIImageView = {
    let iv = UIImageView()
    iv.layer.cornerRadius = 8
    iv.layer.masksToBounds = true
    iv.contentMode = .scaleAspectFill
    return iv
  }()
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupStyles()
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  func setupStyles() {
    self.backgroundColor = .white
  }
  
  func setupLayouts() {
    self.contentView.addSubview(self.imageView)
  }
  
  func setupConstraints() {
    self.imageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
