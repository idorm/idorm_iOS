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

class CustomCalendarCell: UICollectionViewCell {
  // MARK: - Properties
  static let identifier = "CustomCalendarCell"
  
  lazy var dayOfMonthLabel: UILabel = {
    let label = UILabel()
    label.font = .init(name: Font.regular.rawValue, size: 12)
    label.textColor = .idorm_gray_400
    
    return label
  }()
  
  // MARK: - Helpers
  func configureUI(dayOfMonth: String) {
    dayOfMonthLabel.text = dayOfMonth
    
    contentView.addSubview(dayOfMonthLabel)
    
    dayOfMonthLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(4)
    }
  }
}
