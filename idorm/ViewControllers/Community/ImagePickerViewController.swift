//
//  ImagePickerViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/18.
//

import UIKit
import SnapKit
import Photos

class ImagePickerViewController: UIViewController {
    // MARK: - Properties
    var fetchResult: PHFetchResult<PHAsset>?
    let imageManager = PHCachingImageManager()
    
    var photos : [UIImage] = []
    var photoArray: [Int] = []
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        let width = (UIScreen.main.bounds.width - 4) / 3
        layout.itemSize = CGSize(width: width, height: width)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImagePickerCollectionViewCell.self, forCellWithReuseIdentifier: ImagePickerCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        requestCollection()
    }
    
    // MARK: - Selectors
    
    // MARK: - Helpers
    private func configureUI() {
        view.addSubview(collectionView)
        view.backgroundColor = .white
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func requestCollection() {
        let cameraRoll = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        guard let cameraRollCollection = cameraRoll.firstObject else { return }
        let fetchOption = PHFetchOptions()
        fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.fetchResult = PHAsset.fetchAssets(in: cameraRollCollection, options: fetchOption)
        collectionView.reloadData()
    }
}

extension ImagePickerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImagePickerCollectionViewCell.identifier, for: indexPath) as? ImagePickerCollectionViewCell,
            let asset = fetchResult?.object(at: indexPath.row)
        else { return UICollectionViewCell() }
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 130, height: 130), contentMode: .aspectFill, options: nil) { image, _ in
            cell.configureUI(image: image)
        }
        
        cell.numberLabel.isHidden = true
        cell.circle.isHidden = false
        cell.layer.borderWidth = 0

        if !photoArray.isEmpty {
            for i in 0...photoArray.count - 1 {
                if indexPath.item == photoArray[i] {
                    cell.circle.isHidden = true
                    cell.numberLabel.isHidden = false
                    cell.numberLabel.text = "\(i + 1)"
                    cell.layer.borderColor = UIColor.mainColor.cgColor
                    cell.layer.borderWidth = 3
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = fetchResult?.count else { return 0 }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ImagePickerCollectionViewCell
        
        if cell.numberLabel.isHidden {
            if photos.count <= 10 {
                photoArray.append(indexPath.item)
                photos.append(cell.imageView.image!)
            }
        } else {
            photos.remove(at: Int(cell.numberLabel.text!)! - 1)
            photoArray.remove(at: Int(cell.numberLabel.text!)! - 1)
        }
        collectionView.reloadData()
    }
}
