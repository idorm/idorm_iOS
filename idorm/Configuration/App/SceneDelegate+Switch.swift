//
//  SceneDelegate+Switch.swift
//  idorm
//
//  Created by 김응철 on 2023/03/12.
//

import UIKit

extension SceneDelegate {
  /// 루트뷰를 변경합니다.
  func changeRootVC(_ vc: UIViewController, animated: Bool) {
    guard let window = self.window else { return }
    window.rootViewController = vc // 전환
    
    UIView.transition(
      with: window,
      duration: 0.2,
      options: [.transitionCrossDissolve],
      animations: nil,
      completion: nil
    )
  }
}
