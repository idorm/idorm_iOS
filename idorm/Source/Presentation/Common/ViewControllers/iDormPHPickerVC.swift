//
//  iDormPHPickerVC.swift
//  idorm
//
//  Created by 김응철 on 9/28/23.
//

import UIKit

import PhotosUI

final class iDormPHPickerViewController: BaseViewController {
  
  enum ViewType {
    case multiSelection(selectionLimit: Int)
    case singleSelection
  }
  
  // MARK: - Properties
  
  var configuration: PHPickerConfiguration {
    var config = PHPickerConfiguration()
    switch self.viewType {
    case .multiSelection(let selectionLimit):
      config.selectionLimit = selectionLimit
    case .singleSelection:
      config.selectionLimit = 1
    }
    return config
  }
  
  private let viewType: ViewType
  var imagesHandler: (([UIImage]) -> Void)?
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.presentToPickerVC()
  }
  
  // MARK: - Initializer
  
  init(_ viewType: ViewType) {
    self.viewType = viewType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Functions
  
  private func presentToPickerVC() {
    let viewController = PHPickerViewController(configuration: self.configuration)
    viewController.modalPresentationStyle = .overFullScreen
    viewController.delegate = self
    self.present(viewController, animated: true)
  }
}

// MARK: - PHPickerViewControllerDelegate

extension iDormPHPickerViewController: PHPickerViewControllerDelegate {
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    let dispatchGroup = DispatchGroup()
    var selectedImages: [UIImage] = []
    for result in results {
      dispatchGroup.enter()
      if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
        result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
          if let image = image as? UIImage {
            selectedImages.append(image)
          }
          dispatchGroup.leave()
        }
      }
    }
    dispatchGroup.notify(queue: .main) {
      picker.dismiss(animated: true, completion: nil)
      self.dismiss(animated: false)
      self.imagesHandler?(selectedImages)
    }
  }
}
