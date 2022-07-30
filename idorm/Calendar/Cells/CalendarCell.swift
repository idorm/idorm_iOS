//
//  CalendarCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/30.
//

import UIKit
import FSCalendar
import SnapKit

class CalendarCell: FSCalendarCell {
  // MARK: - Properties
  lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .idorm_yellow
    
    return view
  }()
  
  static let identifier = "CalendarCell"
  
  // MARK: - LifeCycle
  
  // MARK: - Helpers
  func configureUI() {
//    switch cellType {
//    case .personal:
//      containerView.backgroundColor = .idorm_blue
//    case .official:
//      containerView.backgroundColor = .idorm_yellow
//    }
    
    contentView.addSubview(containerView)
    
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}

