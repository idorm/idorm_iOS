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
      make.directionalVerticalEdges.equalToSuperview()
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
    }
  }
}
