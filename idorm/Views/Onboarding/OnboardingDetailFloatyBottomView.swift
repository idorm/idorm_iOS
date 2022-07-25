//
//  OnboardingDetailFloatyBottomView.swift
//  idorm
//
//  Created by 김응철 on 2022/07/25.
//

import UIKit
import SnapKit

class OnboardingDetailFloatyBottomView: UIView {
  // MARK: - Properties
  lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOffset = CGSize(width: 0, height: -4)
    view.layer.shadowOpacity = 0.14
    
    return view
  }()
  
  lazy var skipButton: UIButton = {
    var container = AttributeContainer()
    container.font = .init(name: Font.medium.rawValue, size: 16)
    container.foregroundColor = .darkgrey_custom
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .blue_white
    config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 26, bottom: 14, trailing: 26)
    config.attributedTitle = AttributedString("뒤로 가기", attributes: container)
    let button = UIButton(configuration: config)
    
    return button
  }()
  
  lazy var confirmButton: UIButton = {
    var container = AttributeContainer()
    container.font = .init(name: Font.medium.rawValue, size: 16)
    container.foregroundColor = UIColor.white
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .mainColor
    config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 26, bottom: 14, trailing: 26)
    config.attributedTitle = AttributedString("완료", attributes: container)
    let button = UIButton(configuration: config)
    
    return button
  }()

  // MARK: - LifeCycle
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Helpers
  private func configureUI() {
    addSubview(containerView)
    
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    [ skipButton, confirmButton ]
      .forEach { containerView.addSubview($0) }
    
    skipButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.centerY.equalToSuperview()
    }
    
    confirmButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(24)
      make.centerY.equalToSuperview()
    }
  }

}
