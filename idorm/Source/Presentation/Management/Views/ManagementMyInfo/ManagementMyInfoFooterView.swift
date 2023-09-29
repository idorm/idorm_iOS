//
//  ManagementMyInfoFooterView.swift
//  idorm
//
//  Created by 김응철 on 9/29/23.
//

import UIKit

import SnapKit

final class ManagementMyInfoFooterView: BaseReusableView {
  
  // MARK: - UI Components
  
  private let lineView: UIView = {
    let view = UIView()
    view.backgroundColor = .iDormColor(.iDormGray100)
    return view
  }()
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.addSubview(self.lineView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.lineView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.centerY.equalToSuperview()
      make.height.equalTo(6.0)
    }
  }
}
