//
//  CustomCalendarCell.swift
//  idorm
//
//  Created by 김응철 on 2022/08/01.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

enum CalendarCellType {
  case none
  case dorm
  case personal
  case today
}

class CustomCalendarCell: UICollectionViewCell {
  // MARK: - Properties
  static let identifier = "CustomCalendarCell"
  
  lazy var dayOfMonthLabel: UILabel = {
    let label = UILabel()
    label.font = .init(name: Font.regular.rawValue, size: 12)
    label.textColor = .idorm_gray_400
    
    return label
  }()
  
  lazy var todayCircleView: UIView = {
    let view = UIView()
    view.backgroundColor = .idorm_gray_200
    view.layer.cornerRadius = 11
    view.isHidden = true
    
    return view
  }()
  
  lazy var yellowDotView: UIView = {
    let view = UIView()
    view.backgroundColor = .idorm_yellow
    view.layer.cornerRadius = 2
    view.isHidden = true
    
    return view
  }()
  
  lazy var blueDotView: UIView = {
    let view = UIView()
    view.backgroundColor = .idorm_blue
    view.layer.cornerRadius = 2
    view.isHidden = true
    
    return view
  }()
  
  // MARK: - Helpers
  func configureUI(dayOfMonth: String, type: [CalendarCellType]) {
    dayOfMonthLabel.text = dayOfMonth
    
    let dotStack = UIStackView(arrangedSubviews: [ yellowDotView, blueDotView ])
    dotStack.spacing = 4
    
    [ todayCircleView, dotStack, dayOfMonthLabel ]
      .forEach { contentView.addSubview($0) }
    
    dayOfMonthLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(4)
    }
    
    todayCircleView.snp.makeConstraints { make in
      make.width.height.equalTo(22)
      make.center.equalTo(dayOfMonthLabel)
    }
    
    yellowDotView.snp.makeConstraints { make in
      make.width.height.equalTo(4)
    }
    
    blueDotView.snp.makeConstraints { make in
      make.width.height.equalTo(4)
    }
    
    dotStack.snp.makeConstraints { make in
      make.centerX.equalTo(dayOfMonthLabel)
      make.top.equalTo(dayOfMonthLabel.snp.bottom).offset(4)
    }

    if type == [.today] {
      todayCircleView.isHidden = false
    }
    
    if type == [.personal] {
      yellowDotView.isHidden = false
    }
    
    if type == [.dorm] {
      blueDotView.isHidden = false
    }
    
    if type == [.dorm, .personal] {
      blueDotView.isHidden = false
      yellowDotView.isHidden = false
    }
    
    if type == [.none] {
      blueDotView.isHidden = true
      yellowDotView.isHidden = true
      todayCircleView.isHidden = true
    }
  }
}
