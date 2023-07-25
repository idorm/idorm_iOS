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
  
  // MARK: - UI Components
  
  private let circleView: UIView = {
    let view = UIView()
    view.backgroundColor = .iDormColor(.iDormGray200)
    view.layer.cornerRadius = Metric.circleViewSize / 2
    return view
  }()
  
  private lazy var firstDotView = self.colorDotView(.iDormColor(.firstUser))
  private lazy var secondDotView = self.colorDotView(.iDormColor(.secondUser))
  private lazy var thirdDotView = self.colorDotView(.iDormColor(.thirdUser))
  private lazy var fourthDotView = self.colorDotView(.iDormColor(.fourthUser))
  
  /// 네 가지 색상의 `DotView`가 들어있는 배열입니다.
  lazy var dotViews: [UIView] = {
    var views: [UIView] = []
    [self.firstDotView, self.secondDotView, self.thirdDotView, self.fourthDotView]
      .forEach { views.append($0) }
    return views
  }()
  
  private lazy var dotStackView: UIStackView = {
    let stackView = UIStackView()
    self.dotViews.forEach { stackView.addArrangedSubview($0) }
    stackView.spacing = 2
    stackView.axis = .horizontal
    return stackView
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
    self.dotViews.forEach { $0.isHidden = true }
  }
  
  func setupLayouts() {
    [
      self.circleView,
      self.dotStackView
    ].forEach {
      self.contentView.insertSubview($0, at: 0)
    }
  }
  
  func setupConstraints() {
    self.circleView.snp.makeConstraints { make in
      make.center.equalTo(self.titleLabel)
      make.size.equalTo(Metric.circleViewSize)
    }
    
    self.dotStackView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(self.titleLabel.snp.bottom)
    }
    
    self.dotViews.forEach {
      $0.snp.makeConstraints { make in
        make.size.equalTo(4)
      }
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
}

// MARK: - Privates

private extension iDormCalendarCell {
  func colorDotView(_ color: UIColor) -> UIView {
    let view = UIView()
    view.backgroundColor = color
    view.layer.cornerRadius = 2
    return view
  }
}
