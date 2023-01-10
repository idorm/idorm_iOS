//
//  PostCell.swift
//  idorm
//
//  Created by 김응철 on 2023/01/10.
//

import UIKit

import SnapKit

final class PostCell: UICollectionViewCell {
  
  // MARK: - Properties
  
  static let identifier = "PostCell"
  
  let deleteBtn: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "circle_xmark_darkgray"), for: .normal)
    
    return btn
  }()
  
  let imageView: UIImageView = {
    let iv = UIImageView()
    iv.layer.cornerRadius = 10
    iv.backgroundColor = .blue
    
    return iv
  }()
  
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
      imageView,
      deleteBtn
    ].forEach {
      contentView.addSubview($0)
    }
  }

  private func setupConstraints() {
    imageView.snp.makeConstraints { make in
      make.bottom.leading.equalToSuperview()
      make.width.height.equalTo(80)
    }
    
    deleteBtn.snp.makeConstraints { make in
      make.trailing.equalToSuperview().offset(3)
      make.top.equalToSuperview().offset(-3)
      make.width.height.equalTo(25)
    }
  }
}
