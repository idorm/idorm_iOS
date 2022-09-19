//
//  CalendarChipCollectionViewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/27.
//

import SnapKit
import UIKit
import RxCocoa
import RxSwift

class CalendarChipCell: UICollectionViewCell {
  // MARK: - Properties
  lazy var containerView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 15
    view.layer.borderWidth = 1
    view.layer.borderColor = UIColor.idorm_blue.cgColor
    
    return view
  }()
  
  lazy var leftDayLabel: UILabel = {
    let label = UILabel()
    label.font = .init(name: MyFonts.bold.rawValue, size: 12)
    label.textColor = .black
    label.text = "오늘"
    
    return label
  }()
  
  lazy var calendarLabel: UILabel = {
    let label = UILabel()
    label.font = .init(name: MyFonts.regular.rawValue, size: 12)
    label.textColor = .black
    label.text = "간식나눔"
    
    return label
  }()
  
  static let identifier = "CalendarChipCollectionViewCell"
  
  // MARK: - Helpers
  func configureUI() {
    layer.borderColor = UIColor.idorm_blue.cgColor
    layer.borderWidth = 1
    layer.cornerRadius = 15
    contentView.layer.opacity = 0.4
    
    let stack = UIStackView(arrangedSubviews: [ leftDayLabel, calendarLabel ])
    stack.spacing = 4
    
    contentView.addSubview(stack)
    
    stack.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview().inset(6)
      make.leading.trailing.equalToSuperview().inset(10)
    }
  }
}
