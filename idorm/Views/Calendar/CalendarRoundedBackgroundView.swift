//
//  CalendarRoundedBackgroundView.swift
//  idorm
//
//  Created by 김응철 on 2022/07/29.
//

import UIKit
import SnapKit

class CalendarRoundedBackgroundView: UICollectionReusableView {
  // MARK: - Properties
  lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.borderWidth = 1
    view.layer.borderColor = UIColor.idorm_gray_200.cgColor
    view.layer.cornerRadius = 14
    view.clipsToBounds = true
    
    return view
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
    backgroundColor = .clear
    addSubview(containerView)
    
    containerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.bottom.equalToSuperview()
    }
  }
}
