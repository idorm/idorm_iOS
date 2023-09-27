//
//  OnboardingButtonCell.swift
//  idorm
//
//  Created by 김응철 on 9/14/23.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class MatchingInfoSetupButtonCell: BaseCollectionViewCell {
  
  // MARK: - UI Components
  
  /// 메인이 되는 `UIButton`
  private lazy var hoverButton: iDormButton = {
    let button = iDormButton("", image: nil)
    button.baseBackgroundColor = .white
    button.baseForegroundColor = .iDormColor(.iDormGray300)
    button.borderColor = .iDormColor(.iDormGray200)
    button.borderWidth = 1.0
    button.contentInset =
    NSDirectionalEdgeInsets(top: 6.0, leading: 20.0, bottom: 6.0, trailing: 20.0)
    button.cornerRadius = 29.0
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      guard let button = button as? iDormButton else { return }
      switch button.state {
      case .selected:
        button.baseBackgroundColor = .iDormColor(.iDormBlue)
        button.baseForegroundColor = .white
        button.borderColor = .clear
      default:
        button.baseBackgroundColor = .white
        button.baseForegroundColor = .iDormColor(.iDormGray300)
        button.borderColor = .iDormColor(.iDormGray200)
      }
    }
    button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
    button.configurationUpdateHandler = handler
    return button
  }()
  
  // MARK: - Properties
  
  private var item: MatchingInfoSetupSectionItem?
  var buttonTappedHandler: ((MatchingInfoSetupSectionItem) -> Void)?

  // MARK: - Setup

  override func setupStyles() {}
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.addSubview(self.hoverButton)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.hoverButton.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.height.equalTo(33.0)
    }
  }
  
  // MARK: - Selectors
  
  @objc
  private func buttonDidTap() {
    guard let item = self.item else { return }
    self.buttonTappedHandler?(item)
  }
  
  // MARK: - Configure
  
  func configure(with item: MatchingInfoSetupSectionItem) {
    self.item = item
    switch item {
    case let .dormitory(dormitory, isSelected):
      self.hoverButton.title = dormitory.description
      self.hoverButton.isSelected = isSelected
    case let .gender(gender, isSelected):
      self.hoverButton.title = gender.description
      self.hoverButton.isSelected = isSelected
    case let .period(joinPeriod, isSelected):
      self.hoverButton.title = joinPeriod.description
      self.hoverButton.isSelected = isSelected
    case let .habit(habit, isSelected):
      self.hoverButton.title = habit.description
      self.hoverButton.isSelected = isSelected
    default:
      break
    }
  }
}
