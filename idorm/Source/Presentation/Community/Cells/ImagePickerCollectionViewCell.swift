//
//  ImagePickerCollectionViewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/18.
//

import UIKit
import SnapKit
import Photos

class ImagePickerCollectionViewCell: UICollectionViewCell {
  // MARK: - Properties
  static let identifier = "ImagePickerCollectionViewCell"
  var asset: PHAsset = PHAsset()
  
  lazy var imageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = true
    
    return iv
  }()
  
  lazy var circle: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 11
    view.layer.borderColor = UIColor.white.cgColor
    view.layer.borderWidth = 3
    
    return view
  }()
  
  lazy var numberLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = .idorm_blue
    label.textColor = .white
    label.font = .init(name: MyFonts.medium.rawValue, size: 12)
    label.textAlignment = .center
    label.layer.masksToBounds = true
    label.layer.cornerRadius = 11
    label.isHidden = true
    
    return label
  }()
  
  // MARK: - LifeCycle
  
  // MARK: - Selectors
  
  // MARK: - Helpers
  func configureUI(asset: PHAsset) {
    let width = (UIScreen.main.bounds.width - 4) / 3
    imageView.image = asset.getAssetThumbnail(size: CGSize(width: width, height: width))
    self.asset = asset
    
    numberLabel.layer.cornerRadius = circle.frame.height / 2
    
    [ imageView, circle, numberLabel ]
      .forEach { contentView.addSubview($0) }
    
    imageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    circle.snp.makeConstraints { make in
      make.trailing.top.equalToSuperview().inset(6)
      make.width.height.equalTo(22)
    }
    
    numberLabel.snp.makeConstraints { make in
      make.trailing.top.equalToSuperview().inset(6)
      make.width.height.equalTo(22)
    }
  }
}
