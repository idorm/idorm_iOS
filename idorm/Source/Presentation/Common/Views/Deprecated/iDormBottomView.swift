//
//  iDormBottomView.swift
//  idorm
//
//  Created by 김응철 on 7/27/23.
//

import UIKit

import SnapKit

/// 하단에 Floaty처럼 두 개의 버튼이 공존하는 `UIView`
final class iDormBottomView: UIView, BaseViewProtocol {
  
  // MARK: - UI Components
  
  let leftButton: iDormButton
  let rightButton: iDormButton
  
  /// `SafeArea`를 덮을 `UIView`
  private let baseView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    return view
  }()
  
  // MARK: - Properties
  
  /// 오른쪽 버튼의 `isEnabled`를 설정할 수 있는 프로퍼티입니다.
  var isEnabledRightButton: Bool = false {
    willSet { self.rightButton.isEnabled = newValue }
  }
  
  // MARK: - Initializer
  
  /// 이 `iDormBottomView`를 생성하기 위해서는
  /// 왼쪽, 오른쪽 버튼에 대한 정보가 필요합니다.
  ///
  /// - Parameters:
  ///  - leftButton: 왼쪽에 해당하는 버튼
  ///  - rightButton: 오른쪽에 해당하는 버튼
  ///  - bottomInset: 정확한 높이를 위한 VC의 `bottomInset`
  init(leftButton: iDormButton ,rightButton: iDormButton) {
    self.leftButton = leftButton
    self.rightButton = rightButton
    super.init(frame: .zero)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  func setupStyles() {
    // LeftButton
    self.leftButton.edgeInsets = .init(top: 14.0, leading: 24.0, bottom: 14.0, trailing: 24.0)
    self.leftButton.baseBackgroundColor = .iDormColor(.iDormGray100)
    self.leftButton.baseForegroundColor = .iDormColor(.iDormGray400)
    self.leftButton.cornerRadius = 6.0
    self.leftButton.font = .iDormFont(.medium, size: 16.0)
    
    // RightButton
    self.rightButton.edgeInsets = .init(top: 14.0, leading: 24.0, bottom: 14.0, trailing: 24.0)
    self.rightButton.baseBackgroundColor = .iDormColor(.iDormBlue)
    self.rightButton.baseForegroundColor = .white
    self.leftButton.cornerRadius = 6.0
    self.rightButton.font = .iDormFont(.medium, size: 16.0)
    
    // ContentView
    self.backgroundColor = .white
    self.layer.shadowOpacity = 0.14
    self.layer.shadowRadius = 15.5
    self.layer.shadowOffset = CGSize(width: 0.0, height: -1.0)
  }
  
  func setupLayouts() {
    [
      self.leftButton,
      self.rightButton,
      self.baseView
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.snp.makeConstraints { make in
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
    
    self.baseView.snp.makeConstraints { make in
      make.top.equalTo(self.snp.bottom)
      make.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(100.0)
    }
  }
}
