//
//  TransitionManager.swift
//  idorm
//
//  Created by 김응철 on 2023/05/06.
//

import UIKit

final class TransitionManager {
  static let shared = TransitionManager()
  
  var postPushAlarmDidTap: ((Int) -> Void)?
}
