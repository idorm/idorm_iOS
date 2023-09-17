//
//  CalendarHeader.swift
//  idorm
//
//  Created by 김응철 on 7/16/23.
//

import UIKit

import SnapKit

@objc protocol CalendarScheduleHeaderDelegate: AnyObject {
  @objc optional func didTapRemoveCalendarButton()
}

/// `우리방 일정` 또는 `기숙사 일정`이 있는 헤더입니다.
final class CalendarScheduleHeader: UICollectionReusableView, BaseViewProtocol {
  
  enum ViewType: Hashable {
    case teamCalendar
    case dormCalendar
    case Sleepover(canEdit: Bool)
  }
  
  // MARK: - UI Components
  
  private let contentLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.regular, size: 12)
    label.textColor = .iDormColor(.iDormGray400)
    return label
  }()
  
  private lazy var deleteCalendarButton: iDormButton = {
    let button = iDormButton("일정삭제", image: nil)
    button.font = .iDormFont(.regular, size: 12.0)
    button.baseForegroundColor = .iDormColor(.iDormBlue)
    button.baseBackgroundColor = .clear
    button.contentInset = .zero
    button.addTarget(self, action: #selector(self.didTapRemoveCalendarButton), for: .touchUpInside)
    button.isHidden = true
    return button
  }()
  
  // MARK: - Properties
  
  weak var delegate: CalendarScheduleHeaderDelegate?
  
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
    self.backgroundColor = .white
  }
  
  func setupLayouts() {
    [
      self.contentLabel,
      self.deleteCalendarButton
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.contentLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.bottom.equalToSuperview().inset(12.0)
    }
    
    self.deleteCalendarButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview()
      make.centerY.equalTo(self.contentLabel)
    }
  }
  
  // MARK: - Selectors
  
  @objc
  private func didTapRemoveCalendarButton() {
    self.delegate?.didTapRemoveCalendarButton?()
  }
  
  // MARK: - Configure
  
  /// 헤더의 레이블에 들어갈 텍스트를 주입합니다.
  ///
  /// - Parameters:
  ///  - viewType: 분기처리된 ViewType
  func configure(_ viewType: ViewType) {
    switch viewType {
    case .teamCalendar:
      self.contentLabel.text = "우리방 일정"
    case .dormCalendar:
      self.contentLabel.text = "기숙사 일정"
    case .Sleepover(let canEdit):
      self.deleteCalendarButton.isHidden = true
      self.contentLabel.text = "외박 일정"
      if canEdit {
        self.deleteCalendarButton.isHidden = false
      }
    }
  }
}
