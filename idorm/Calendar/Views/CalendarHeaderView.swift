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

class CalendarHeaderView: UIView {
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
    
    return label
  }()
  
  lazy var roundedBackgroundView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 24.0
    
    return view
  }()
  
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

    monthLabel.text = transformDateToString(date)
    
    [ leftArrowButton, rightArrowButton, monthLabel, roundedBackgroundView ]
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
    
    roundedBackgroundView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(monthLabel.snp.bottom).offset(10)
      make.bottom.equalToSuperview()
    }
  }
  
  func transformDateToString(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "M월"
    return formatter.string(from: date)
  }
}
