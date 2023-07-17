//
//  PostCell.swift
//  idorm
//
//  Created by 김응철 on 2023/01/10.
//

import UIKit

import SnapKit
import Photos

final class PostingPhotoCell: UICollectionViewCell {
  
  // MARK: - Properties
  
  private lazy var deleteBtn: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "circle_xmark_darkgray"), for: .normal)
    btn.addTarget(self, action: #selector(didTapDeleteBtn), for: .touchUpInside)
    
    return btn
  }()
  
  let imageView: UIImageView = {
    let iv = UIImageView()
    iv.layer.cornerRadius = 10
    iv.layer.masksToBounds = true
    iv.contentMode = .scaleAspectFit
    return iv
  }()
  
  var deleteCompletion: (() -> Void)?
  
  // MARK: - LifeCycle
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupStyles()
    setupLayout()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupStyles() {
    contentView.backgroundColor = .white
  }
  
  private func setupLayout() {
    [
      self.imageView,
      self.deleteBtn
    ].forEach {
      self.contentView.addSubview($0)
    }
  }
  
  private func setupConstraints() {
    self.imageView.snp.makeConstraints { make in
      make.bottom.leading.equalToSuperview()
      make.width.height.equalTo(80)
    }
    
    self.deleteBtn.snp.makeConstraints { make in
      make.trailing.equalToSuperview().offset(3)
      make.top.equalToSuperview().offset(-3)
      make.width.height.equalTo(25)
    }
  }
  
  func setupImage(_ image: UIImage) {
    self.imageView.image = image
  }
  
  // MARK: - ACTIONS
  
  @objc
  private func didTapDeleteBtn() {
    self.deleteCompletion?()
  }
}
