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
  
  // MARK: - UI
  
  let mainImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.kf.indicatorType = .activity
    return iv
  }()
  
  private lazy var pinchGesture: UIPinchGestureRecognizer = {
    let pg = UIPinchGestureRecognizer(
      target: self,
      action: #selector(handlePinch(_:))
    )
    return pg
  }()
  
  // MARK: - Properties
  
  static let identifier = "DetailPhotoCell"
  
  var recognizerScale: CGFloat = 1.0
  var maxScale: CGFloat = 2.0
  var minScale: CGFloat = 1.0
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Selectors
  
  @objc
  private func handlePinch(_ pinch: UIPinchGestureRecognizer) {
    guard mainImageView.image != nil else { return }
    
    if pinch.state == .began || pinch.state == .changed {
      // 확대
      if (recognizerScale < maxScale && pinch.scale > 1.0) {
        mainImageView.transform = (mainImageView.transform).scaledBy(
          x: pinch.scale,
          y: pinch.scale
        )
        recognizerScale *= pinch.scale
        pinch.scale = 1.0
      } // 축소
      else if (recognizerScale > minScale && pinch.scale < 1.0) {
        mainImageView.transform = (mainImageView.transform).scaledBy(
          x: pinch.scale,
          y: pinch.scale
        )
        recognizerScale *= pinch.scale
        pinch.scale = 1.0
      }
    }
  }
  
  // MARK: - Helpers
  
  /// 명시적으로 호출되어야 합니다.
  func injectImage(_ url: String) {
    mainImageView.kf.setImage(with: URL(string: url))
//    contentView.addGestureRecognizer(pinchGesture)
  }
}

// MARK: - SETUP

extension DetailPhotoCell: BaseView {
  func setupStyles() {
    contentView.backgroundColor = .black
  }
  
  func setupLayouts() {
    contentView.addSubview(mainImageView)
  }
  
  func setupConstraints() {
    mainImageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
