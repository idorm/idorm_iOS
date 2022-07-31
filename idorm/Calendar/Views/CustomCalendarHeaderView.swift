//
//  MainCalendarHeaderView.swift
//  idorm
//
//  Created by 김응철 on 2022/07/29.
//

import SnapKit
import UIKit
import RxSwift
import RxCocoa
import FSCalendar

class CustomCalendarHeaderView: UIView {
  // MARK: - Properties
  lazy var leftArrowButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
    button.tintColor = .idorm_gray_400
    
    return button
  }()
  
  lazy var rightArrowButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
    button.tintColor = .idorm_gray_400
    
    return button
  }()
  
  lazy var monthLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = .init(name: Font.medium.rawValue, size: 16)
    label.text = "6월"
    
    return label
  }()
  
  lazy var roundedBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 24.0
    
    return view
  }()
  
  lazy var sundayLabel = createWeekDayLabel(title: "일")
  lazy var mondayLabel = createWeekDayLabel(title: "월")
  lazy var tuesdayLabel = createWeekDayLabel(title: "화")
  lazy var wednesdayLabel = createWeekDayLabel(title: "수")
  lazy var thursdayLabel = createWeekDayLabel(title: "목")
  lazy var fridayLabel = createWeekDayLabel(title: "금")
  lazy var saturdayLabel = createWeekDayLabel(title: "토")
  
  let disposeBag = DisposeBag()
  
  /// Input
  var arrowButtonPublisher = PublishSubject<Bool>()
  
  /// Output
  var onChangedMonth = PublishSubject<Date>()
  
  // MARK: - LifeCycle
  override init(frame: CGRect) {
    super.init(frame: frame)
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Bind
  private func bind() {
    leftArrowButton.rx.tap
      .map { false }
      .bind(to: arrowButtonPublisher)
      .disposed(by: disposeBag)
    
    rightArrowButton.rx.tap
      .map { true }
      .bind(to: arrowButtonPublisher)
      .disposed(by: disposeBag)
    
    onChangedMonth
      .map { [weak self] date in
        self?.transformDateToString(date)
      }
      .bind(to: monthLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  func configureUI(date: Date) {
    backgroundColor = .idorm_gray_100
    roundedBackgroundView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
    
    let weekdayStack = UIStackView(arrangedSubviews: [ sundayLabel, mondayLabel, tuesdayLabel, wednesdayLabel, thursdayLabel, fridayLabel, saturdayLabel ])
    weekdayStack.distribution = .equalSpacing
    weekdayStack.isLayoutMarginsRelativeArrangement = true
    weekdayStack.layoutMargins = UIEdgeInsets(top: 10.5, left: 17.5, bottom: 10.5, right: 17.5)
    
    monthLabel.text = transformDateToString(date)
    
    [ leftArrowButton, rightArrowButton, monthLabel, roundedBackgroundView, weekdayStack ]
      .forEach { addSubview($0) }
    
    leftArrowButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(16)
      make.top.equalToSuperview().inset(10)
    }
    
    rightArrowButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(16)
      make.top.equalToSuperview().inset(10)
    }
    
    monthLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(10)
    }
    
    weekdayStack.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(monthLabel.snp.bottom).offset(30)
      make.bottom.equalToSuperview()
    }
    
    roundedBackgroundView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(monthLabel.snp.bottom).offset(10)
      make.bottom.equalTo(weekdayStack.snp.bottom)
    }
  }
  
  func transformDateToString(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "M월"
    return formatter.string(from: date)
  }
}

extension CustomCalendarHeaderView {
  func createWeekDayLabel(title: String) -> UILabel {
    let label = UILabel()
    label.text = title
    label.font = .init(name: Font.regular.rawValue, size: 12)
    if title == "일" || title == "토" {
      label.textColor = .idorm_red
    } else {
      label.textColor = .idorm_gray_400
    }
    
    return label
  }
}
