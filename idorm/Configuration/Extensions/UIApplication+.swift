//
//  UIApplication+.swift
//  idorm
//
//  Created by 김응철 on 7/7/23.
//

import Foundation
import UIKit

extension UIApplication {
  /// 최상단 ViewController를 참조할 수 있게 도와주는 메서드입니다.
  func topViewController(
    _ base: UIViewController? = (
      UIApplication.shared.connectedScenes.first as? UIWindowScene
    )?.windows.first?.rootViewController
  ) -> UIViewController {
    if let nav = base as? UINavigationController {
      return topViewController(nav.visibleViewController)
    }
    
    if let tab = base as? UITabBarController {
      if let selected = tab.selectedViewController {
        return topViewController(selected)
      }
    }
    
    if let presented = base?.presentedViewController {
      return topViewController(presented)
    }
    
    return base!
  }
  
  /// 현재 `BottomInset`의 값을 구할 수 있도록 도와주는 메서드입니다.
  var bottomInset: CGFloat {
    let scenes = UIApplication.shared.connectedScenes
    let windowScene = scenes.first as? UIWindowScene
    let window = windowScene?.windows.first
    return window?.safeAreaInsets.bottom ?? 0.0
  }
}
