//
//  MatchingContainerView.swift
//  idorm
//
//  Created by 김응철 on 2022/12/22.
//

import UIKit

import SnapKit
import Then

final class MatchingContainerView: UIView {
  
  // MARK: - Properties
  
  private let titleLabel = UILabel().then {
    $0.text = "룸메이트 매칭 관리"
    $0.textColor = .black
    $0.font = .iDormFont(.medium, size: 16)
  }
  
  private let shareLabel = UILabel().then {
    $0.text = "내 이미지 매칭페이지에 공유하기"
    $0.textColor = .black
    $0.font = .init(name: IdormFont_deprecated.medium.rawValue, size: 14)
  }
  
  private lazy var buttonStack = UIStackView().then { stack in
    [matchingImageButton, likeButton, dislikeButton]
      .forEach { stack.addArrangedSubview($0) }
    stack.axis = .horizontal
    stack.spacing = 12
  }
  
  private lazy var shareStack = UIStackView().then { stack in
    [shareLabel, shareButton]
      .forEach { stack.addArrangedSubview($0) }
    stack.axis = .horizontal
    stack.spacing = 8
  }
  
  let shareButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .selected:
        button.configuration?.image = #imageLiteral(resourceName: "ellipse_blue_activated")
      default:
        button.configuration?.image = UIImage(named: "ellipse_gray")
        button.configuration?.baseBackgroundColor = .clear
      }
    }
    $0.configuration = config
    $0.configurationUpdateHandler = handler
  }
  
  lazy var matchingImageButton = button(image: #imageLiteral(resourceName: "circle_image"), title: "매칭 이미지")
  lazy var likeButton = button(image: #imageLiteral(resourceName: "circle_heart_blue"), title: "좋아요한 룸메")
  lazy var dislikeButton = button(image: #imageLiteral(resourceName: "circle_dislike_blue"), title: "싫어요한 룸메")
  
  // MARK: - LifeCycle
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    setupStyles()
    setupLayout()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupStyles() {
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 5)
    layer.shadowOpacity = 0.1
    backgroundColor = .white
  }
  
  private func setupLayout() {
    [titleLabel, buttonStack, shareStack]
      .forEach { addSubview($0) }
  }
  
  private func setupConstraints() {
    titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalToSuperview().inset(16)
    }
    
    buttonStack.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
    }
    
    shareStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(20)
      make.top.equalTo(buttonStack.snp.bottom).offset(20)
      make.bottom.equalToSuperview().inset(16)
    }
  }
}

// MARK: - Helpers

extension MatchingContainerView {
  private func button(image: UIImage, title: String) -> UIButton {
    var config = UIButton.Configuration.filled()
    config.image = image
    config.imagePlacement = .top
    config.imagePadding = 8
    var container = AttributeContainer()
    container.font = .init(name: IdormFont_deprecated.regular.rawValue, size: 12)
    container.foregroundColor = UIColor.black
    config.attributedTitle = AttributedString(title, attributes: container)
    config.titleAlignment = .center
    config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 4, bottom: 12, trailing: 4)
    config.baseBackgroundColor = .idorm_gray_100
    let button = UIButton(configuration: config)
    button.layer.cornerRadius = 12
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .highlighted:
        button.configuration?.baseBackgroundColor = .idorm_gray_200
      default:
        button.configuration?.baseBackgroundColor = .idorm_gray_100
      }
    }
    button.configurationUpdateHandler = handler
    button.layer.shadowOffset = CGSize(width: 0, height: 2)
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOpacity = 0.1
    
    return button
  }  
}
