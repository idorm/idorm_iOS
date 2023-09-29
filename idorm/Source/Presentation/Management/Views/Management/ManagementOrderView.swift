//
//  ManagementOrderView.swift
//  idorm
//
//  Created by 김응철 on 9/29/23.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class ManagementOrderView: BaseView {
  
  // MARK: - UI Components
  
  private lazy var lastestButton: iDormButton = {
    let button = iDormButton("최신순")
    button.baseBackgroundColor = .clear
    button.baseForegroundColor = .black
    button.contentInset = .zero
    button.imagePlacement = .trailing
    button.imagePadding = 9.0
    button.font = .iDormFont(.regular, size: 14.0)
    button.configurationUpdateHandler = self.updateHandler
    return button
  }()
  
  private lazy var pastButton: iDormButton = {
    let button = iDormButton("과거순")
    button.baseBackgroundColor = .clear
    button.baseForegroundColor = .black
    button.contentInset = .zero
    button.imagePlacement = .trailing
    button.imagePadding = 9.0
    button.font = .iDormFont(.regular, size: 14.0)
    button.configurationUpdateHandler = self.updateHandler
    return button
  }()
  
  private lazy var updateHandler: UIButton.ConfigurationUpdateHandler = { button in
    guard let button = button as? iDormButton else { return }
    switch button.state {
    case .selected: button.image = .iDormIcon(.select)
    default: button.image = .iDormIcon(.deselect)
    }
  }
  
  var buttonHandler: ((_ isLastest: Bool) -> Void)?
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.backgroundColor = .iDormColor(.iDormGray100)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.lastestButton,
      self.pastButton
    ].forEach {
      self.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.lastestButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().inset(24.0)
    }
    
    self.pastButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalTo(self.lastestButton.snp.trailing).offset(17.5)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    self.lastestButton.rx.tap.asDriver()
      .drive(with: self) { owner, _ in
        owner.buttonHandler?(true)
      }
      .disposed(by: self.disposeBag)
    
    self.pastButton.rx.tap.asDriver()
      .drive(with: self) { owner, _ in
        owner.buttonHandler?(false)
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  func toggleButton(isLastest: Bool) {
    self.lastestButton.isSelected = isLastest
    self.pastButton.isSelected = !isLastest
  }
}
