//
//  ImagePickerViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/18.
//

import UIKit

import SnapKit
import Photos

final class GalleryViewController: UIViewController {
  
  // MARK: - Properties
    
  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 2
    layout.minimumInteritemSpacing = 2
    let width = (UIScreen.main.bounds.width - 4) / 3
    layout.itemSize = CGSize(width: width, height: width)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.register(GalleryCell.self, forCellWithReuseIdentifier: GalleryCell.identifier)
    collectionView.dataSource = self
    collectionView.delegate = self
    
    return collectionView
  }()
  
  private lazy var countLabel: UILabel = {
    let label = UILabel()
    label.font = .init(name: MyFonts.medium.rawValue, size: 16)
    label.textColor = .idorm_blue
    
    return label
  }()
  
  private lazy var confirmButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitle("완료", for: .normal)
    button.titleLabel?.font = .init(name: MyFonts.bold.rawValue, size: 16)
    button.setTitleColor(UIColor.idorm_gray_300, for: .normal)
    button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
    
    return button
  }()
  
  private let indicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView()
    indicator.color = .darkGray
    
    return indicator
  }()
  
  var fetchResult: PHFetchResult<PHAsset>?
  let currentPhotoCount: Int
  
  /// 선택된 사진 Numbering Properties
  var photoArray: [Int] = []
  var selectedAsset: [PHAsset] = []

  var completion: (([PHAsset]) -> Void)?
  
  // MARK: - LifeCycle
  
  init(count: Int) {
    self.currentPhotoCount = count
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    fetchImagesFromGallery()
  }
  
  // MARK: - Selectors
  
  @objc
  private func didTapConfirmButton() {
    indicator.startAnimating()
    self.completion?(selectedAsset)
    navigationController?.popViewController(animated: true)
  }
  
  // MARK: - Helpers
  
  private func configureUI() {
    let confirmStack = UIStackView(arrangedSubviews: [countLabel, confirmButton])
    confirmStack.axis = .horizontal
    confirmStack.spacing = 4
    
    [
      collectionView,
      indicator
    ].forEach {
      view.addSubview($0)
    }
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: confirmStack)
    navigationItem.title = "모든 사진"
    view.backgroundColor = .white
    
    collectionView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  private func fetchImagesFromGallery() {
    let cameraRollCollection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
    guard let cameraRoll = cameraRollCollection.firstObject else { return }
    DispatchQueue.main.async {
      let fetchOptions = PHFetchOptions()
      fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
      self.fetchResult = PHAsset.fetchAssets(in: cameraRoll, options: fetchOptions)
      self.collectionView.reloadData()
    }
  }
}

// MARK: - CollectionView Setup

extension GalleryViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    guard
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCell.identifier, for: indexPath) as? GalleryCell,
      let asset = fetchResult?.object(at: indexPath.row)
    else {
      return UICollectionViewCell()
    }
    
    cell.configureUI(asset: asset)
    
    countLabel.text = "\(photoArray.count)"
    
    cell.numberLabel.isHidden = true
    cell.circle.isHidden = false
    cell.layer.borderWidth = 0
    if !photoArray.isEmpty {
      for i in 0...photoArray.count - 1 {
        if indexPath.item == photoArray[i] {
          cell.circle.isHidden = true
          cell.numberLabel.isHidden = false
          cell.numberLabel.text = "\(i + 1)"
          cell.layer.borderColor = UIColor.idorm_blue.cgColor
          cell.layer.borderWidth = 3
        }
      }
    }
    return cell
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    if let count = fetchResult?.count {
      return count
    }
    return 0
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    let cell = collectionView.cellForItem(at: indexPath) as! GalleryCell
    
    if cell.numberLabel.isHidden {
      if photoArray.count < 10 - currentPhotoCount {
        photoArray.append(indexPath.item)
        selectedAsset.append(cell.asset)
      }
    } else {
      selectedAsset.remove(at: Int(cell.numberLabel.text!)! - 1)
      photoArray.remove(at: Int(cell.numberLabel.text!)! - 1)
    }
    collectionView.reloadData()
  }
}
