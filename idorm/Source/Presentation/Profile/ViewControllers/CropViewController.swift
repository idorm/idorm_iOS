//
//  CropViewController.swift
//  idorm
//
//  Created by 김응철 on 2023/05/01.
//

import UIKit

final class CropViewController: BaseViewController {
  
  // MARK: - Properties
  
  var completion: ((UIImage) -> Void)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let imagePickerController = UIImagePickerController()
    imagePickerController.sourceType = .photoLibrary
    imagePickerController.delegate = self
    imagePickerController.allowsEditing = true // 이미지를 편집할 수 있도록 설정
    imagePickerController.modalPresentationStyle = .overFullScreen
    present(imagePickerController, animated: true, completion: nil)
  }
  
  // MARK: - Helpers
  
  // 이미지를 정사각형으로 crop하는 메서드
  func squareImage(from image: UIImage) -> UIImage? {
    let originalSize = image.size
    let imageSize = min(originalSize.width, originalSize.height)
    let x = (originalSize.width - imageSize) / 2.0
    let y = (originalSize.height - imageSize) / 2.0
    let cropRect = CGRect(x: x, y: y, width: imageSize, height: imageSize)
    if let imageRef = image.cgImage?.cropping(to: cropRect) {
      return UIImage(cgImage: imageRef, scale: UIScreen.main.scale, orientation: image.imageOrientation)
    }
    return nil
  }
}

// MARK: - Picker Delegate

extension CropViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
  ) {
    picker.dismiss(animated: true)
    if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
      completion?(image)
    }
    dismiss(animated: false, completion: nil)
  }
  
  func imagePickerControllerDidCancel(
    _ picker: UIImagePickerController
  ) {
    picker.dismiss(animated: true)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
      self?.dismiss(animated: false, completion: nil)
    }
  }
}
