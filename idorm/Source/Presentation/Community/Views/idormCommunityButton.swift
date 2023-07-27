//
//  idormCommunityButton.swift
//  idorm
//
//  Created by 김응철 on 2023/01/23.
//

import UIKit

final class idormCommunityButton: UIButton {
  
  // MARK: - Initializer
  
  init(_ title: String) {
    super.init(frame: .zero)
    
    var config = UIButton.Configuration.filled()
    config.background.cornerRadius = 4
    config.baseBackgroundColor = .idorm_gray_100
    config.baseForegroundColor = .black
    
    var titleContainer = AttributeContainer()
    titleContainer.font = .iDormFont(.regular, size: 12)
    
    config.attributedTitle = AttributedString(title, attributes: titleContainer)
    
    self.configuration = config
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
