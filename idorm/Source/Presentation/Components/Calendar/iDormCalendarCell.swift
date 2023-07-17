//
//  iDormCalendarCell.swift
//  idorm
//
//  Created by 김응철 on 7/8/23.
//

import UIKit

import FSCalendar
import SnapKit

final class iDormCalendarCell: FSCalendarCell, BaseView {
  
  private enum Metric {
    static let circleViewSize: CGFloat = 22.0
  }
  
  // MARK: - Properties
  
  /// 현재 어떤 캘린더를 사용하는지 알 수 있습니다.
  private var viewType: iDormCalendar.ViewType = .main
  
  // MARK: - UI Components
  
  private let circleView: UIView = {
    let view = UIView()
    view.backgroundColor = .iDormColor(.iDormGray200)
    view.layer.cornerRadius = Metric.circleViewSize / 2
    return view
  }()
  
  // MARK: - LifeCycle
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
  }
  
  // MARK: - Setup
  
  func setupStyles() {
    self.shapeLayer.isHidden = true
    switch self.viewType {
    case .main:
      break
    case .sub:
      self.circleView.isHidden = true
    }
  }
  
  func setupLayouts() {
    [
      self.circleView
    ].forEach {
      self.contentView.insertSubview($0, at: 0)
    }
  }
  
  func setupConstraints() {
    self.circleView.snp.makeConstraints { make in
      make.center.equalTo(self.titleLabel)
      make.size.equalTo(Metric.circleViewSize)
    }
  }

  // MARK: - Override
  
  /// 셀을 선택했을 때 불려지는 메서드입니다.
  override func performSelecting() {
    self.titleLabel.textColor = .white
    self.contentView.backgroundColor = .iDormColor(.iDormBlue)
  }
  
  /// 셀의 이벤트가 들어왔을 때 무조건적으로 불려지는 메서드입니다.
  override func configureAppearance() {
    super.configureAppearance()
    
    self.contentView.backgroundColor = self.isSelected ? .iDormColor(.iDormBlue) : .white
    self.circleView.backgroundColor = self.dateIsToday ? .iDormColor(.iDormGray200) : .clear
  }
  
  // MARK: - Configure
  
  /// 현재 셀이 `iDormCalendar`가 어떤 `ViewType`을 갖고 있는지 구성하는 메서드입니다.
  ///
  /// - Parameters:
  ///  - viewType: `iDormCalendar`의 `ViewType`
  func configureViewType(_ viewType: iDormCalendar.ViewType) {
    self.viewType = viewType
  }
  
  func configureCalendar(_ date: Date, calendar: TeamCalendar) {
    
  }
}
