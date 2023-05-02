//
//  CommunityContainerView.swift
//  idorm
//
//  Created by 김응철 on 2023/04/11.
//

import UIKit

import Then
import SnapKit

final class CommunityContainerView: UIView {
  
  // MARK: - Properties
  
  private let titleLabel = UILabel().then {
    $0.text = "커뮤니티 관리"
    $0.textColor = .black
    $0.font = .idormFont(.medium, size: 16)
  }
  
  lazy var myPostButton = button(
    image: UIImage(named: "circle_pencil_blue"),
    title: "내가 쓴 글"
  )
  
  lazy var myCommentButton = button(
    image: UIImage(named: "circle_speechBubble_blue"),
    title: "내가 쓴 댓글"
  )
  
  lazy var myRecommendButton = button(
    image: UIImage(named: "circle_thumbs"),
    title: "추천한 글"
  )
  
  private lazy var buttonStack: UIStackView = {
    let sv = UIStackView()
    [
      myPostButton,
      myCommentButton,
      myRecommendButton
    ].forEach {
      sv.addArrangedSubview($0)
    }
    sv.spacing = 12
    sv.axis = .horizontal
    return sv
  }()
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupStyles()
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Helpers
  
  private func button(image: UIImage?, title: String) -> UIButton {
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

// MARK: - Setup

extension CommunityContainerView: BaseView {
  func setupStyles() {
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 5)
    layer.shadowOpacity = 0.1
    backgroundColor = .white
  }
  
  func setupLayouts() {
    [
      titleLabel,
      buttonStack
    ].forEach {
      addSubview($0)
    }
  }
  
  func setupConstraints() {
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(16)
      make.leading.equalToSuperview().inset(20)
    }
    
    buttonStack.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(20)
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
      make.bottom.equalToSuperview().inset(16)
    }
  }
}
