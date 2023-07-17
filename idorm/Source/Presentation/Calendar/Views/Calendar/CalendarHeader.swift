//
//  CalendarHeader.swift
//  idorm
//
//  Created by 김응철 on 7/16/23.
//

import UIKit

import SnapKit

final class CalendarHeader: UICollectionReusableView, BaseView {
  
  // MARK: - UI Components
  
  let dormCalendar: iDormCalendar = {
    let calendar = iDormCalendar(.main)
    return calendar
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
    self.addSubview(self.dormCalendar)
  }
  
  func setupConstraints() {
    self.dormCalendar.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
