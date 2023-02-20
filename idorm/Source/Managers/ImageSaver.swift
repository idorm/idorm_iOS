//
//  ImageSaver.swift
//  idorm
//
//  Created by 김응철 on 2023/02/20.
//

import UIKit

class ImageSaver: NSObject {
  func writeToPhotoAlbum(image: UIImage) {
    UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
  }
  
  @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    self.saveCompletion?()
  }
  
  var saveCompletion: (() -> Void)?
}
