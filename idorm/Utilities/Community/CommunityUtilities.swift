//
//  CommunityUtilities.swift
//  idorm
//
//  Created by 김응철 on 2022/07/21.
//

import UIKit

class CommunityUtilities {
  static func getSeparatorLine() -> UIView {
    let view = UIView()
    view.backgroundColor = .bluegrey
    
    return view
  }
  
  static func getCountLabel() -> UILabel {
    let label = UILabel()
    label.text = "100"
    label.font = .init(name: Font.medium.rawValue, size: 10)
    label.textColor = .grey_custom
    
    return label
  }
}
