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
    btn.setImage(UIImage(named: "xmark_white"), for: .normal)
    btn.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
    
    return btn
  }()
  
  private lazy var saveButton: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "save"), for: .normal)
    btn.addTarget(self, action: #selector(saveButtonDidTap), for: .touchUpInside)
    
    return btn
  }()
  
  private lazy var photoCollectionView: UICollectionView = {
    let layout = UICollectionViewCompositionalLayout(section: self.section)
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.register(
      DetailPhotoCell.self,
      forCellWithReuseIdentifier: DetailPhotoCell.identifier
    )
    cv.backgroundColor = .black
    cv.dataSource = self
    cv.isScrollEnabled = false
    cv.showsHorizontalScrollIndicator = false
    
    return cv
  }()
  
  private lazy var section: NSCollectionLayoutSection = {
    let size = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .fractionalHeight(1.0)
    )
    let item = NSCollectionLayoutItem(layoutSize: size)
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .paging
    
    section.visibleItemsInvalidationHandler = { _, offset, _ in
      let width = self.photoCollectionView.frame.width
      self.currentIndex = Int(offset.x / width)
    }
    
    return section
  }()
  
  // MARK: - PROPERTIES
  
  private let photosURL: [String]
  private var currentIndex: Int
  override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
  
  // MARK: - INITIALIZER
  
  init(_ photosURL: [String], currentIndex: Int) {
    self.photosURL = photosURL
    self.currentIndex = currentIndex
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - LIFE CYCLE
  
  override func viewDidLayoutSubviews() {
    self.photoCollectionView.scrollToItem(
      at: IndexPath(item: self.currentIndex, section: 0),
      at: .centeredHorizontally,
      animated: false
    )
  }
  
  // MARK: - SETUP
  
  override func setupStyles() {
    self.view.backgroundColor = .black
  }
  
  override func setupLayouts() {
    [
      self.closeButton,
      self.saveButton,
      self.photoCollectionView
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.closeButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(18)
      make.top.equalTo(self.view.safeAreaLayoutGuide).inset(10)
    }
    
    self.saveButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(18)
      make.top.equalTo(self.view.safeAreaLayoutGuide).inset(10)
    }
    
    self.photoCollectionView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.bottom.equalTo(self.view.safeAreaLayoutGuide)
      make.top.equalTo(self.closeButton.snp.bottom).offset(8)
    }
  }
  
  // MARK: - ACTIONS
  
  @objc
  private func closeButtonDidTap() {
    self.dismiss(animated: true)
  }
  
  @objc
  private func saveButtonDidTap() {
    let indexPath = IndexPath(row: self.currentIndex, section: 0)
    guard let cell = self.photoCollectionView.cellForItem(at: indexPath) as? DetailPhotoCell,
          let photo = cell.mainImageView.image
    else {
      return
    }
    
    let imageSaver = ImageSaver()
    imageSaver.writeToPhotoAlbum(image: photo)
    imageSaver.saveCompletion = { [weak self] in
      let alertVC = UIAlertController(
        title: "사진이 저장되었습니다.",
        message: nil,
        preferredStyle: .alert
      )
      alertVC.addAction(UIAlertAction(title: "확인", style: .cancel))
      self?.present(alertVC, animated: true)
    }
  }
}

// MARK: - SETUP COLLECTIONVIEW

extension DetailPhotosViewController: UICollectionViewDataSource {
  // 셀 갯수
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return photosURL.count
  }
  
  // 셀 생성
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: DetailPhotoCell.identifier,
      for: indexPath
    ) as? DetailPhotoCell
    else {
      return UICollectionViewCell()
    }
    cell.injectImage(self.photosURL[indexPath.row])
    
    return cell
  }
}
