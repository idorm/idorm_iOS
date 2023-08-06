//
//  CalendarCell.swift
//  idorm
//
//  Created by 김응철 on 2023/05/02.
//

import UIKit

import SnapKit

/// 기숙사 공식 일정 리스트의 `Cell`입니다.
final class DormCalendarCell: UICollectionViewCell, BaseView {
  
  // MARK: - UI Components
  
  /// 둥근 모서리가 있는 `View`
  private let containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    view.layer.borderWidth = 1
    view.layer.borderColor = UIColor.idorm_gray_200.cgColor
    view.layer.cornerRadius = 14
    return view
  }()
  
  /// `ic_right`에셋이 들어있는 `UIButton`
  private let rightArrowButton: UIButton = {
    let btn = UIButton()
    btn.setImage(.iDormIcon(.right), for: .normal)
    return btn
  }()
  
  /// 시작 날짜와 종료 날짜가 포함되어 있는 `UILabel`
  private let dateLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.regular, size: 14)
    label.textColor = .black
    return label
  }()
  
  /// 기숙사 공식 일정의 콘텐츠가 적혀있는 `UILabel`
  private let contentLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.regular, size: 14)
    label.textColor = .black
    return label
  }()
  
  /// `일정이 있는 기숙사`가 적혀있는 `UILabel`
  private let dormWithScheduleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .iDormColor(.iDormGray300)
    label.text = "일정이 있는 기숙사"
    label.font = .iDormFont(.regular, size: 12)
    return label
  }()
  
  /// 기숙사 별 `UIButton`입니다.
  /// 사용자의 `Interaction`이 제한되어 있습니다.
  private lazy var dorm1Button = makeDormButton(dorm: .no1)
  private lazy var dorm2Button = makeDormButton(dorm: .no2)
  private lazy var dorm3Button = makeDormButton(dorm: .no3)
  private lazy var dormButtons: [UIButton] = {
    var buttons: [UIButton] = []
    [self.dorm1Button, self.dorm2Button, self.dorm3Button]
      .forEach { buttons.append($0) }
    return buttons
  }()
  
  /// `dormButtons`가 포함되어 있는 기숙사 `UIStackView`
  private lazy var dormButtonStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: self.dormButtons)
    stackView.axis = .horizontal
    stackView.spacing = 4.0
    return stackView
  }()
  
  /// `장소`가 적혀있는 `UILabel`입니다.
  private let locationLabel: UILabel = {
    let label = UILabel()
    label.textColor = .iDormColor(.iDormGray300)
    label.text = "장소"
    label.font = .iDormFont(.regular, size: 12)
    return label
  }()
  
  /// 기숙사 공식 일정의 구체적인 장소가 적혀있는 `UILabel`
  private let scheduleLocationLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.regular, size: 12)
    label.textColor = .iDormColor(.iDormGray400)
    label.setContentHuggingPriority(.init(rawValue: 200), for: .horizontal)
    return label
  }()
  
  /// 장소와 관련된 UI의 `UIStackView`
  private lazy var locationStackView: UIStackView = {
    let stackView = UIStackView()
    [self.locationLabel, self.scheduleLocationLabel]
      .forEach { stackView.addArrangedSubview($0) }
    stackView.spacing = 4.0
    stackView.axis = .horizontal
    stackView.alignment = .leading
    return stackView
  }()
  
  /// `시간`이 적혀있는 `UILabel`입니다.
  private let timeLabel: UILabel = {
    let label = UILabel()
    label.textColor = .iDormColor(.iDormGray300)
    label.text = "시간"
    label.font = .iDormFont(.regular, size: 12)
    return label
  }()
  
  /// 기숙사 공식 일정의 구체적인 시간이 적혀있는 `UILabel`
  private let scheduleTimeLabel: UILabel = {
    let label = UILabel()
    label.textColor = .iDormColor(.iDormGray400)
    label.font = .iDormFont(.regular, size: 12)
    label.setContentHuggingPriority(.init(rawValue: 200), for: .horizontal)
    return label
  }()
  
  /// 시간과 관련된 UI의 `UIStackView`
  private lazy var timeStackView: UIStackView = {
    let stackView = UIStackView()
    [self.timeLabel, self.scheduleTimeLabel]
      .forEach { stackView.addArrangedSubview($0) }
    stackView.spacing = 4.0
    stackView.axis = .horizontal
    return stackView
  }()
  
  // MARK: - Properties
  
  /// `Cell`의 `Height`를 조절하는 프로퍼티 입니다.
  private var heightConstraint: Constraint?
  
  private var height: CGFloat = 150.0 {
    didSet { self.heightConstraint?.update(offset: self.height) }
  }
  
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
  
  func setupStyles() {
    contentView.backgroundColor = .white
  }
  
  func setupLayouts() {
    self.contentView.addSubview(self.containerView)
    
    [
      self.dateLabel,
      self.contentLabel,
      self.rightArrowButton,
      self.dormWithScheduleLabel,
      self.dormButtonStackView,
      self.locationStackView,
      self.timeStackView
    ].forEach { self.containerView.addSubview($0) }
  }
  
  func setupConstraints() {
    self.containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      self.heightConstraint = make.height.equalTo(150.0).constraint
    }
    
    self.dateLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(22.0)
      make.leading.equalToSuperview().inset(32.0)
    }
    
    self.contentLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(32.0)
      make.trailing.equalTo(self.rightArrowButton.snp.leading).offset(-16.0)
      make.top.equalTo(self.dateLabel.snp.bottom).offset(2.0)
    }
    
    self.rightArrowButton.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(22)
      make.trailing.equalToSuperview().inset(24.0)
    }
    
    self.dormWithScheduleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(32.0)
      make.top.equalTo(self.contentLabel.snp.bottom).offset(14.0)
    }
    
    self.dormButtonStackView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(32.0)
      make.top.equalTo(self.dormWithScheduleLabel.snp.bottom).offset(4.0)
    }
    
    self.locationStackView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(32.0)
      make.top.equalTo(self.dormButtonStackView.snp.bottom).offset(14.0)
    }
    
    self.timeStackView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(32.0)
      make.top.equalTo(self.locationStackView.snp.bottom).offset(4.0)
    }
  }
  
  // MARK: - Configure
  
  /// 실 데이터를 가지고 UI를 업데이트합니다.
  func configure(with calendar: DormCalendar) {
    /// 어떤 데이터가 `nil`값이 된다면 이 값이 하나씩 올라갑니다.
    /// 최종 높이 값을 계산하여 제약조건을 업데이트합니다.
    var heightCount: Int = 0
    
    // Date
    self.dateLabel.text = calendar.startDate?.toDateString(from: "yyyy-MM-dd", to: "M월 d일")
    if let endDate = calendar.endDate {
      self.dateLabel.text?.append(" ~ \(endDate.toDateString(from: "yyyy-MM-dd", to: "M월 d일"))")
    }
    
    // Content
    self.contentLabel.text = calendar.content
    
    // Dorm
    self.dorm1Button.isHidden = !calendar.isDorm1Yn
    self.dorm2Button.isHidden = !calendar.isDorm2Yn
    self.dorm3Button.isHidden = !calendar.isDorm3Yn
    
    // Location
    if let location = calendar.location {
      self.locationStackView.isHidden = false
      self.scheduleLocationLabel.text = location
    } else {
      self.locationStackView.isHidden = true
      heightCount += 1
    }
    
    // Time
    if calendar.startTime == nil,
       calendar.endTime == nil {
      self.timeStackView.isHidden = true
      heightCount += 1
    } else {
      self.timeStackView.isHidden = false
      self.scheduleTimeLabel.text = calendar.startTime?.toDateString(from: "HH:mm:ss", to: "a h:mm")
      if let endTime = calendar.endTime {
        self.scheduleTimeLabel.text?.append(" ~ \(endTime.toDateString(from: "HH:mm:ss", to: "a h:mm"))")
      }
    }
    
    // AutoHeight
    switch heightCount {
    case 0:
      self.height = 204.0
    case 1:
      self.height = 182.0
    default:
      self.height = 150.0
    }
  }
  
  @available(*, deprecated, renamed: "configure", message: "BYE")
  func configure(_ calendar: CalendarResponseModel.Calendar) {}
}

// MARK: - Privates

private extension DormCalendarCell {
  /// 기숙사별 `UIButton`의 UI를 간편하게 만들어줍니다.
  ///
  /// - Parameters:
  ///  - dorm: 원하는 기숙사
  ///
  /// - Returns:
  /// 직사각형의 기숙사 정보가 들어있는 `UIButton`
  func makeDormButton(dorm: Dormitory) -> UIButton {
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
        .font: UIFont.iDormFont(.regular, size: 12),
        .foregroundColor: UIColor.idorm_gray_400,
      ])
    )
    config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
    config.background.cornerRadius = 0
    let button = UIButton(configuration: config)
    button.isEnabled = false
    return button
  }
}
