//
//  CalendarCell.swift
//  idorm
//
//  Created by 김응철 on 2023/05/02.
//

import UIKit

import SnapKit

final class CalendarCell: UICollectionViewCell, BaseView {
  
  // MARK: - UI Components
  
  private let containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    view.layer.borderWidth = 1
    view.layer.borderColor = UIColor.idorm_gray_200.cgColor
    view.layer.cornerRadius = 14
    return view
  }()
  
  private let blueDotView: UIView = {
    let view = UIView()
    view.backgroundColor = .idorm_blue
    view.layer.cornerRadius = 3.5
    return view
  }()
  
  private let rightArrowButton: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "rightArrow"), for: .normal)
    return btn
  }()
  
  private lazy var tildeLabel = UIFactory.label(
    "~",
    textColor: .black,
    font: .idormFont(.regular, size: 14)
  )
  
  private let dormLabel = UIFactory.label(
    "일정이 있는 기숙사",
    textColor: .idorm_gray_300,
    font: .idormFont(.regular, size: 12)
  )
  
  private let locationLabel = UIFactory.label(
    "장소",
    textColor: .idorm_gray_300,
    font: .idormFont(.regular, size: 12)
  )
  
  private let timeLabel = UIFactory.label(
    "시간",
    textColor: .idorm_gray_300,
    font: .idormFont(.regular, size: 12)
  )
  
  private let locationDesriptionLabel = UIFactory.label(
    "1기숙사 현관",
    textColor: .idorm_gray_400,
    font: .idormFont(.regular, size: 12)
  )
  
  private let firstTimeLabel = UIFactory.label(
    "오전 10:00",
    textColor: .idorm_gray_400,
    font: .idormFont(.regular, size: 12)
  )
  
  private let endTimeLabel = UIFactory.label(
    "오후 10:00",
    textColor: .idorm_gray_400,
    font: .idormFont(.regular, size: 12)
  )
  
  private let timeTildeLabel = UIFactory.label(
    "~",
    textColor: .idorm_gray_400,
    font: .idormFont(.regular, size: 12)
  )
  
  private lazy var dormButtonStack: UIStackView = {
    let sv = UIStackView()
    [
      dorm1Button,
      dorm2Button,
      dorm3Button
    ].forEach {
      sv.addArrangedSubview($0)
    }
    sv.spacing = 4
    sv.axis = .horizontal
    return sv
  }()
  
  private lazy var firstDateLabel = dateLabel()
  private lazy var endDateLabel = dateLabel()
  private lazy var titleLabel = dateLabel()
  private lazy var dorm1Button = dormButton(dorm: .no1)
  private lazy var dorm2Button = dormButton(dorm: .no2)
  private lazy var dorm3Button = dormButton(dorm: .no3)
  
  // MARK: - Properties
  
  static let identifier = "CalendarCell"
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupStyles()
    setupLayouts()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  func setupStyles() {
    contentView.backgroundColor = .white
    locationLabel.setContentCompressionResistancePriority(.init(751), for: .horizontal)
  }
  
  func setupLayouts() {
    contentView.addSubview(containerView)
    
    [
      blueDotView,
      titleLabel,
      firstDateLabel,
      endDateLabel,
      tildeLabel,
      rightArrowButton,
      dormLabel,
      dormButtonStack,
      locationLabel, locationDesriptionLabel,
      timeLabel, timeTildeLabel, firstTimeLabel, endTimeLabel
    ].forEach {
      containerView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    containerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalToSuperview().inset(12)
      make.height.equalTo(204)
    }
    
    blueDotView.snp.makeConstraints { make in
      make.width.height.equalTo(7)
      make.leading.equalToSuperview().inset(29)
      make.top.equalToSuperview().inset(40.5)
    }
    
    firstDateLabel.snp.makeConstraints { make in
      make.leading.equalTo(blueDotView.snp.trailing).offset(12)
      make.top.equalToSuperview().inset(22)
    }
    
    tildeLabel.snp.makeConstraints { make in
      make.centerY.equalTo(firstDateLabel)
      make.leading.equalTo(firstDateLabel.snp.trailing).offset(4)
    }
    
    endDateLabel.snp.makeConstraints { make in
      make.centerY.equalTo(firstDateLabel)
      make.leading.equalTo(tildeLabel.snp.trailing).offset(4)
    }
    
    titleLabel.snp.makeConstraints { make in
      make.leading.equalTo(blueDotView.snp.trailing).offset(12)
      make.top.equalTo(firstDateLabel.snp.bottom).offset(2)
      make.trailing.equalToSuperview().inset(32)
    }
    
    rightArrowButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(21)
      make.top.equalToSuperview().inset(22)
    }
    
    dormLabel.snp.makeConstraints { make in
      make.leading.equalTo(firstDateLabel)
      make.top.equalTo(titleLabel.snp.bottom).offset(14)
    }
    
    dormButtonStack.snp.makeConstraints { make in
      make.leading.equalTo(firstDateLabel)
      make.top.equalTo(dormLabel.snp.bottom).offset(4)
    }
    
    locationLabel.snp.makeConstraints { make in
      make.leading.equalTo(firstDateLabel)
      make.top.equalTo(dormButtonStack.snp.bottom).offset(14)
    }
    
    timeLabel.snp.makeConstraints { make in
      make.leading.equalTo(firstDateLabel)
      make.top.equalTo(locationLabel.snp.bottom).offset(4)
    }
    
    locationDesriptionLabel.snp.makeConstraints { make in
      make.leading.equalTo(locationLabel.snp.trailing).offset(4)
      make.trailing.equalTo(rightArrowButton.snp.trailing)
      make.centerY.equalTo(locationLabel)
    }

    firstTimeLabel.snp.makeConstraints { make in
      make.leading.equalTo(timeLabel.snp.trailing).offset(4)
      make.centerY.equalTo(timeLabel)
    }

    timeTildeLabel.snp.makeConstraints { make in
      make.leading.equalTo(firstTimeLabel.snp.trailing).offset(4)
      make.centerY.equalTo(firstTimeLabel)
    }

    endTimeLabel.snp.makeConstraints { make in
      make.centerY.equalTo(firstTimeLabel)
      make.leading.equalTo(timeTildeLabel.snp.trailing).offset(4)
    }
  }
  
  // MARK: - Helpers
  
  func configure(_ calendar: CalendarResponseModel.Calendar) {
    setupConstraints()
    
    firstDateLabel.text = toDate(calendar.startDate!)
    endDateLabel.text = toDate(calendar.endDate!)
    titleLabel.text = calendar.content
    dorm1Button.isHidden = !calendar.isDorm1Yn
    dorm2Button.isHidden = !calendar.isDorm2Yn
    dorm3Button.isHidden = !calendar.isDorm3Yn
    locationDesriptionLabel.text = calendar.location
    firstTimeLabel.text = toTime(calendar.startTime)
    endTimeLabel.text = toTime(calendar.endTime)
  }
  
  private func dateLabel() -> UILabel {
    return UIFactory.label(
      "안녕하세요",
      textColor: .black,
      font: .idormFont(.regular, size: 14)
    )
  }
  
  private func dormButton(dorm: Dormitory) -> UIButton {
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .idorm_gray_200
    config.baseForegroundColor = .idorm_gray_400
    let title: String
    switch dorm {
    case .no1: title = "1 기숙사"
    case .no2: title = "2 기숙사"
    case .no3: title = "3 기숙사"
    }
    config.attributedTitle = AttributedString(
      title,
      attributes: .init([
        .font: UIFont.idormFont(.regular, size: 12),
        .foregroundColor: UIColor.idorm_gray_400,
      ])
    )
    config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
    config.background.cornerRadius = 0
    let button = UIButton(configuration: config)
    button.isEnabled = false
    return button
  }
  
  private func toDate(_ dateString: String?) -> String {
    guard let dateString = dateString else { return "" }
    let dateFormatter = DateFormatter()

    dateFormatter.dateFormat = "yyyy-MM-dd"
    let date = dateFormatter.date(from: dateString)

    dateFormatter.dateFormat = "M월 d일"
    let resultString = dateFormatter.string(from: date!)

    return resultString
  }
  
  private func toTime(_ timeString: String?) -> String {
    guard let timeString = timeString else { return "" }

    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ko_KR")
    dateFormatter.dateFormat = "HH:mm:ss"

    let date = dateFormatter.date(from: timeString)

    dateFormatter.dateFormat = "a h:mm"
    let resultString = dateFormatter.string(from: date!)
    return resultString
  }
}
