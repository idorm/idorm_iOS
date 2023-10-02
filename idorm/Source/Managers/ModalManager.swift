//
//  AlertManager.swift
//  idorm
//
//  Created by 김응철 on 7/7/23.
//

import UIKit

/// 최상단 뷰에서 화면을 관리하는 매니저입니다.
final class ModalManager {
  
  // MARK: - Functions
  
  static func presentPopupVC(
    _ viewType: iDormPopupViewController.ViewType,
    buttonHandler: (() -> Void)? = nil
  ) {
    let viewController = iDormPopupViewController(viewType)
    viewController.modalPresentationStyle = .overFullScreen
    viewController.confirmButtonHandler = { buttonHandler?() }
    UIApplication.shared.topViewController().present(viewController, animated: false)
  }
  
  static func presentBottomSheetVC(
    _ items: [BottomSheetItem],
    buttonHandler: ((BottomSheetItem) -> Void)? = nil
  ) {
    let viewController = BottomSheetViewController(items: items)
    viewController.modalPresentationStyle = .overFullScreen
    viewController.buttonHandler = { buttonHandler?($0) }
    UIApplication.shared.topViewController().presentPanModal(viewController)
  }
  
  static func presentImagePickerVC(
    _ viewType: iDormImagePickerViewController.ViewType,
    imagePickerHandler: @escaping (([UIImage]) -> Void)
  ) {
    let viewController = iDormImagePickerViewController(viewType)
    viewController.modalPresentationStyle = .overFullScreen
    viewController.imagesHandler = { imagePickerHandler($0) }
    UIApplication.shared.topViewController().present(viewController, animated: true)
  }
  
  static func presentChangeProfileImageAlert(
    removeHandler: @escaping (() -> Void),
    updateHandler: @escaping (() -> Void)
  ) {
    let removeAction = UIAlertAction(title: "프로필 사진 삭제", style: .destructive) {_ in removeHandler() }
    let updateAction = UIAlertAction(title: "프로필 사진 변경", style: .default) { _ in updateHandler() }
    let cancelAction = UIAlertAction(title: "취소", style: .cancel)
    let alertController = UIAlertController()
    alertController.addAction(updateAction)
    alertController.addAction(removeAction)
    alertController.addAction(cancelAction)
    UIApplication.shared.topViewController().present(alertController, animated: true)
  }
}
