//
//  ImageManager.swift
//  idorm
//
//  Created by 김응철 on 9/28/23.
//

import UIKit

import Kingfisher

/// `url`과 이미지간의 유틸리티 메서드 모음인 `ImageManager`
final class ImageDownloader {
  
  // MARK: - Functions
  
  /// 이미지를 다운로드하고 이를 `UIImage`로 변환하는 메서드
  static func downloadImage(from url: String, completion: @escaping (UIImage?) -> Void) {
    guard let url = URL(string: url) else { return }
    KingfisherManager.shared.retrieveImage(with: url) { result in
      switch result {
      case .success(let imageResult):
        completion(imageResult.image)
      case .failure(let error):
        print("❌ 이미지를 가져오지 못했습니다. \(error.localizedDescription)")
        completion(nil)
      }
    }
  }
}
