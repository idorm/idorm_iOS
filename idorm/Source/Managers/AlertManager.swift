//
//  AlertManager.swift
//  idorm
//
//  Created by 김응철 on 7/7/23.
//

import UIKit

/// 최상단 뷰에서 알람을 관리하는 매니저입니다.
final class AlertManager {

  // MARK: - Properties
  
  /// 이 클래스는 싱글톤 패턴을 사용합니다.
  static let shared = AlertManager()
  
  /// 최상단 뷰 컨트롤러를 참조할 수 있습니다.
  var topViewController: UIViewController {
    return UIApplication.shared.topViewController()
  }
  
  // MARK: - Functions
  
  /// 최상단 뷰의 팝업 메세지를 띄웁니다.
  ///
  /// - Parameters:
  ///    - message: 팝업에 사용자에게 알릴 메세지 `String`입니다.
  func showAlertPopup(_ message: String?) {
    guard let message else { return }
    let popup = iDormPopupViewController(contents: message)
    popup.modalPresentationStyle = .overFullScreen
    self.topViewController.present(popup, animated: false)
  }
}
