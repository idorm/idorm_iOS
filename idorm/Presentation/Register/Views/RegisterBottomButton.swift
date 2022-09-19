//
//  BottomConfirmButton.swift
//  idorm
//
//  Created by 김응철 on 2022/09/19.
//

import UIKit

final class RegisterBottomButton: UIButton {
  // MARK: - Init
  init(_ title: String) {
    super.init(frame: .zero)
    setupButton(title)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  private func setupButton(_ title: String) {
    var config = UIButton.Configuration.filled()
    var container = AttributeContainer()
    container.foregroundColor = .white
    container.font = .init(name: MyFonts.regular.rawValue, size: 14)
    config.attributedTitle = AttributedString(title, attributes: container)
    config.baseBackgroundColor = .idorm_blue
    config.background.cornerRadius = 10
    
    self.configuration = config
  }
}
