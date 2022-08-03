//
//  SetCalendarViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/08/03.
//

import PanModal
import UIKit

enum SetCalendarVcType {
  case start
  case end
}

class SetCalendarViewController: UIViewController {
  // MARK: - Properties
  let type: SetCalendarVcType
  
  // MARK: - LifeCycle
  init(type: SetCalendarVcType) {
    self.type = type
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Bind
  private func bind() {
    
  }
  
  // MARK: - Helpers
  private func configureUI() {
    
  }
}
