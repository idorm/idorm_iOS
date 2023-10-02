//
//  iDormProfileImageView.swift
//  idorm
//
//  Created by 김응철 on 10/1/23.
//

import UIKit

import SnapKit

final class iDormProfileImageView: BaseView {
  
  // MARK: - UI Components
  
  private let shadowView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    view.layer.cornerRadius = 12.0
    view.layer.shadowOpacity = 0.11
    view.layer.shadowRadius = 2.0
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOffset = CGSize(width: .zero, height: 2.0)
    return view
  }()
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .iDormImage(.human)
    imageView.layer.cornerRadius = 12.0
    imageView.contentMode = .scaleAspectFill
//    imageView.layer.masksToBounds = true
    return imageView
  }()
  
  // MARK: - Properties
  
  var image: UIImage? {
    willSet {
      self.imageView.image = newValue
    }
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.backgroundColor = .clear
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.shadowView,
      self.imageView
    ].forEach {
      self.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.shadowView.snp.makeConstraints { make in
      make.size.equalTo(68.0)
      make.centerX.top.equalToSuperview()
    }
    
    self.imageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
