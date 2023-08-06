//
//  TeamCalendarBackgroundView.swift
//  idorm
//
//  Created by 김응철 on 7/17/23.
//

import UIKit

import SnapKit

/// `CornerRadius`가 들어가 있는 셀을 감싸는 뷰입니다.
final class TeamCalendarBackgroundView: UICollectionReusableView, BaseView {
  
  // MARK: - UI Components
  
  private let containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    view.layer.cornerRadius = 14.0
    view.layer.borderWidth = 1
    view.layer.borderColor = UIColor.iDormColor(.iDormGray200).cgColor
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
  
  func setupStyles() {
    self.backgroundColor = .white
  }
  
  func setupLayouts() {
    self.addSubview(self.containerView)
  }
  
  func setupConstraints() {
    self.containerView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(45.0)
      make.directionalHorizontalEdges.equalToSuperview().inset(24)
      make.bottom.equalToSuperview()
    }
  }
}
