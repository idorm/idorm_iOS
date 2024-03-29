//
//  UINavigationController+Extensions.swift
//  idorm
//
//  Created by 김응철 on 2022/12/26.
//

import UIKit

extension UINavigationController {
  
  func pushViewController(_ viewController: UIViewController, animated: Bool = true, completion: @escaping () -> Void) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    pushViewController(viewController, animated: animated)
    CATransaction.commit()
  }
  
  func popViewController(animated: Bool = true, completion: @escaping () -> Void) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    popViewController(animated: animated)
    CATransaction.commit()
  }
  
  func popToRootViewController(animated: Bool = true, completion: @escaping () -> Void) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    popToRootViewController(animated: animated)
    CATransaction.commit()
  }
}
