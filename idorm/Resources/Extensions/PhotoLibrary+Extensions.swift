//
//  Extensions+PHPhotoLibrary.swift
//  idorm
//
//  Created by 김응철 on 2022/07/19.
//

import Foundation
import Photos
import UIKit

extension PHPhotoLibrary {
  static func checkAuthorizationStatus(completion: @escaping (_ status: Bool) -> Void) {
    if PHPhotoLibrary.authorizationStatus(for: .readWrite) == PHAuthorizationStatus.authorized {
      completion(true)
    } else {
      PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
        if newStatus == PHAuthorizationStatus.authorized {
          completion(true)
        } else {
          completion(false)
        }
      }
    }
  }
}

extension PHAssetCollection {
  func getCoverImgWithSize(_ size: CGSize) -> UIImage! {
    let assets = PHAsset.fetchAssets(in: self, options: nil)
    let asset = assets.firstObject
    return asset?.getAssetThumbnail(size: size)
  }
  
  func hasAssets() -> Bool {
    let assets = PHAsset.fetchAssets(in: self, options: nil)
    return assets.count > 0
  }
}

extension PHAsset {
  func getAssetThumbnail(size: CGSize) -> UIImage {
    let manager = PHImageManager.default()
    let option = PHImageRequestOptions()
    var thumbnail = UIImage()
    option.isSynchronous = true
    manager.requestImage(for: self, targetSize: size, contentMode: .aspectFill, options: option) { result, info in
      thumbnail = result!
    }
    return thumbnail
  }
  
  func getOriginalImage(completion: @escaping (UIImage) -> Void) {
    let manager = PHImageManager.default()
    let option = PHImageRequestOptions()
    var image = UIImage()
    manager.requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: option) { result, info in
      image = result!
      completion(image)
    }
  }
  
  func getImageFromPHAsset() -> UIImage {
    var image = UIImage()
    let requestOptions = PHImageRequestOptions()
    requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
    requestOptions.isSynchronous = true
    
    if self.mediaType == PHAssetMediaType.image {
      PHImageManager.default().requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: requestOptions) { pickedImage, info in
        image = pickedImage!
      }
    }
    
    return image
  }
}
