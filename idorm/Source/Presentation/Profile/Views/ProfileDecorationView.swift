//
//  ProfileDecorationView.swift
//  idorm
//
//  Created by 김응철 on 9/29/23.
//

import UIKit

import SnapKit

final class ProfileDecorationView: BaseReusableView {
  
  // MARK: - UI Components
  
  private let containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 12.0
    view.layer.shadowOpacity = 0.11
    view.layer.shadowRadius = 2.0
    view.layer.shadowOffset = CGSize(width: .zero, height: 2.0)
    return view
  }()
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.addSubview(self.containerView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.containerView.snp.makeConstraints { make in
      make.bottom.top.equalToSuperview()
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
    }
  }
}
