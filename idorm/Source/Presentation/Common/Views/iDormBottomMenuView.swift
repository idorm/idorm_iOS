//
//  iDormBottomMenuView.swift
//  idorm
//
//  Created by 김응철 on 9/17/23.
//

import UIKit

import SnapKit

final class iDormBottomMenuView: BaseView {
  
  // MARK: - UI Components
  
  /// 버튼들을 포함하는 `UIView`
  private let containerView: UIView = {
    let view = UIView()
    view.layer.shadowOpacity = 0.14
    view.layer.shadowRadius = 15.5
    view.layer.shadowOffset = CGSize(width: 0, height: -1)
    view.backgroundColor = .white
    return view
  }()
  
  /// SafeArea를 덮을 수 있는 `UIView`
  private let safeAreaCoverView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    return view
  }()
  
  /// 왼쪽 `UIButton`
  private lazy var leftButton: iDormButton = {
    let button = iDormButton("", image: nil)
    button.baseBackgroundColor = .iDormColor(.iDormGray100)
    button.baseForegroundColor = .iDormColor(.iDormGray400)
    button.font = .iDormFont(.medium, size: 16.0)
    button.cornerRadius = 6.0
    button.addTarget(self, action: #selector(self.leftButtonDidTap), for: .touchUpInside)
    button.contentInset =
    NSDirectionalEdgeInsets(top: 14.0, leading: 26.0, bottom: 14.0, trailing: 26.0)
    return button
  }()
  
  /// 오른쪽 `UIButton`
  private lazy var rightButton: iDormButton = {
    let button = iDormButton("", image: nil)
    button.baseBackgroundColor = .iDormColor(.iDormBlue)
    button.baseForegroundColor = .white
    button.font = .iDormFont(.medium, size: 16.0)
    button.cornerRadius = 6.0
    button.addTarget(self, action: #selector(self.rightButtonDidTap), for: .touchUpInside)
    button.contentInset =
    NSDirectionalEdgeInsets(top: 14.0, leading: 26.0, bottom: 14.0, trailing: 26.0)
    return button
  }()
  
  // MARK: - Properties
  
  var leftButtonHandler: (() -> Void)?
  var rightButtonHandler: (() -> Void)?
  
  // MARK: - Setup
  
  override func setupLayouts() {
    self.addSubview(self.containerView)
    self.addSubview(self.safeAreaCoverView)
    [
      self.leftButton,
      self.rightButton,
    ].forEach {
      self.containerView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.height.equalTo(76.0)
    }
    
    self.leftButton.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(12.0)
      make.leading.equalToSuperview().inset(24.0)
    }
    
    self.rightButton.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(12.0)
      make.trailing.equalToSuperview().inset(24.0)
    }
    
    self.safeAreaCoverView.snp.makeConstraints { make in
      make.top.equalTo(self.containerView.snp.bottom)
      make.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(200.0)
    }
  }
  
  // MARK: - Selectors
  
  @objc
  private func leftButtonDidTap() {
    self.leftButtonHandler?()
  }
  
  @objc
  private func rightButtonDidTap() {
    self.rightButtonHandler?()
  }
  
  // MARK: - Functions
  
  func updateTitle(left: String, right: String) {
    self.leftButton.title = left
    self.rightButton.title = right
  }
}
