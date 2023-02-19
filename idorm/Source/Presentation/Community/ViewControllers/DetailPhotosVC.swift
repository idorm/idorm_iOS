//
//  PhotoListVC.swift
//  idorm
//
//  Created by 김응철 on 2023/02/18.
//

import UIKit

import SnapKit

final class DetailPhotosViewController: BaseViewController {
  
  // MARK: - UI COMPONENTS
  
  private lazy var closeButton: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "xmark_black"), for: .normal)
    btn.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
    
    return btn
  }()
  
  private lazy var photoCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    
    return cv
  }()
  
  private let photosURL: [String]
  
  // MARK: - PROPERTIES
  
  // MARK: - INITIALIZER
  
  init(_ photosURL: [String]) {
    self.photosURL = photosURL
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - SETUP
  
  override func setupStyles() {
    
  }
  
  // MARK: - ACTIONS
  
  @objc
  private func closeButtonDidTap() {
    self.dismiss(animated: true)
  }
}

// MARK: - SETUP COLLECTIONVIEW

extension DetailPhotosViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return 2
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    return UICollectionViewCell()
  }
}
