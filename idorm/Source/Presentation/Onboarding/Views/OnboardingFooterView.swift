//
//  OnboardingFooterView.swift
//  idorm
//
//  Created by 김응철 on 9/15/23.
//

import UIKit

import SnapKit

final class OnboardingFooterView: UICollectionReusableView, BaseViewProtocol {
  
  // MARK: - UI Components
  
  /// 얇은 선으로 구성되어 있는 `UIView`
  private let lineView: UIView = {
    let view = UIView()
    view.backgroundColor = .iDormColor(.iDormGray300)
    return view
  }()
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  func setupStyles() {}
  
  func setupLayouts() {
    self.addSubview(self.lineView)
  }
  
  func setupConstraints() {
    self.lineView.snp.makeConstraints { make in
      make.bottom.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(0.2)
    }
  }
}
