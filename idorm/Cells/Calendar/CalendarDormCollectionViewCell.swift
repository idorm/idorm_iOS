//
//  CalendarBasicCollectionViewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/27.
//

import SnapKit
import UIKit
import RxSwift
import RxCocoa

class CalendarDormTableViewCell: UITableViewCell {
  // MARK: - Properties
  lazy var circleView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 3.5
    view.layer.masksToBounds = true
    view.backgroundColor = .idorm_blue
    
    return view
  }()
  
  lazy var timeLabel: UILabel = {
    let label = UILabel()
    label.font = .init(name: Font.medium.rawValue, size: 12)
    label.textColor = .black
    label.text = "6월 12일"
    
    return label
  }()
  
  lazy var contentsLabel: UILabel = {
    let label = UILabel()
    label.font = .init(name: Font.regular.rawValue, size: 12)
    label.textColor = .idorm_gray_300
    label.text = "간식 나눔"
    
    return label
  }()
  
  lazy var rightArrowButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
    button.tintColor = .idorm_gray_400
    
    return button
  }()
  
  static let identifier = "CalendarDormTableViewCell"
  
  // MARK: - Helpers
  func configureUI() {
    [ circleView, timeLabel, contentsLabel, rightArrowButton ]
      .forEach { contentView.addSubview($0) }
    
    circleView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalToSuperview().inset(5.5)
      make.width.height.equalTo(7)
    }
    
    timeLabel.snp.makeConstraints { make in
      make.leading.equalTo(circleView.snp.trailing).offset(8)
      make.centerY.equalTo(circleView)
    }
    
    contentsLabel.snp.makeConstraints { make in
      make.leading.equalTo(timeLabel.snp.leading)
      make.top.equalTo(timeLabel.snp.bottom)
    }
    
    rightArrowButton.snp.makeConstraints { make in
      make.centerY.equalTo(timeLabel)
      make.trailing.equalToSuperview().inset(24)
    }
  }
}
