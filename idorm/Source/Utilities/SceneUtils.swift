//
//  SceneUtils.swift
//  idorm
//
//  Created by 김응철 on 2023/03/12.
//

import UIKit

enum SceneUtils {
  /// RootVC를 Switch합니다.
  static func switchRootVC(to vc: UIViewController, animated: Bool) {
    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?
      .changeRootVC(vc, animated: animated)
  }
}
