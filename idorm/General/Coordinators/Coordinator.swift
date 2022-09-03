//
//  Coordinators.swift
//  idorm
//
//  Created by 김응철 on 2022/09/03.
//

import UIKit

protocol Coordinator: AnyObject {
  var childCoordinators: [Coordinator] { get set }
  var navigationController: UINavigationController { get set }
  
  func start()
}
