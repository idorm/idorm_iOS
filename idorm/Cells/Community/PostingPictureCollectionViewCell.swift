//
//  WritePictureCollectionViewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/18.
//

import UIKit
import SnapKit
import Photos
import RxCocoa
import RxSwift

protocol PostingPictureCollectionViewCellDelegate: AnyObject {
  func didTapXmarkbutton(asset: PHAsset)
}

class PostingPictureCollectionViewCell: UICollectionViewCell {
  // MARK: - Properties
  static let identifier = "WritePictureCollectionViewCell"
  var currentAsset: PHAsset?
  weak var delegate: PostingPictureCollectionViewCellDelegate?
  
  lazy var imageView: UIImageView = {
    let iv = UIImageView()
    iv.clipsToBounds = true
    iv.contentMode = .scaleAspectFill
    iv.layer.cornerRadius = 10
    iv.backgroundColor = .idorm_blue
    
    return iv
  }()
  
  lazy var xmarkButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "removeImageXmark"), for: .normal)
    button.addTarget(self, action: #selector(didTapXmarkButton), for: .touchUpInside)
    
    return button
  }()
  
  // MARK: - LifeCycle
  
  // MARK: - Selectors
  @objc private func didTapXmarkButton() {
    guard let asset = currentAsset else { return }
    delegate?.didTapXmarkbutton(asset: asset)
  }
  
  // MARK: - Helpers
  func configureUI(asset: PHAsset) {
    imageView.image = asset.getAssetThumbnail(size: CGSize(width: 80, height: 80))
    self.currentAsset = asset
    contentView.backgroundColor = .white
    
    [ imageView, xmarkButton ]
      .forEach { contentView.addSubview($0) }
    
    imageView.snp.makeConstraints { make in
      make.leading.bottom.equalToSuperview()
      make.width.height.equalTo(80)
    }
    
    xmarkButton.snp.makeConstraints { make in
      make.top.equalTo(imageView).offset(-6)
      make.trailing.equalTo(imageView).offset(6)
    }
  }
}
