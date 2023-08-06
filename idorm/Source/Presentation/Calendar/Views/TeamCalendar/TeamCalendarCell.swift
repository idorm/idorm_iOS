//
//  TeamCalendarCell.swift
//  idorm
//
//  Created by 김응철 on 7/16/23.
//

import UIKit

import SnapKit

final class TeamCalendarCell: UICollectionViewCell, BaseView {
  
  // MARK: - UI Components
  
  /// 오른쪽 방향의 아이콘인 `UIButton`
  private let rightButton: UIButton = {
    let button = UIButton()
    button.setImage(.iDormIcon(.right), for: .normal)
    return button
  }()
  
  /// 일정의 날짜를 보여주는 `UILabel`
  private let dateLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.medium, size: 12)
    label.text = "6월 30일"
    return label
  }()
  
  /// 일정의 상세 내역을 보여주는 `UILabel`
  private let contentLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.regular, size: 12)
    label.textColor = .iDormColor(.iDormGray300)
    label.text = "청소"
    return label
  }()
  
  /// 사용자의 전용 색깔을 표시해주는 `View`
  private lazy var firstUserDotView = self.makeDotView(.iDormColor(.firstUser))
  private lazy var secondUserDotView = self.makeDotView(.iDormColor(.secondUser))
  private lazy var thirdUserDotView = self.makeDotView(.iDormColor(.thirdUser))
  private lazy var fourthUserDotView = self.makeDotView(.iDormColor(.fourthUser))
  
  /// `DotView`를 모아둔 배열
  private lazy var dotViews: [UIView] = {
    var views = [UIView]()
    [
      self.firstUserDotView,
      self.secondUserDotView,
      self.thirdUserDotView,
      self.fourthUserDotView
    ].forEach {
      views.append($0)
    }
    return views
  }()
  
  /// `DotView`의 `UIStackView`
  private lazy var dotStackView: UIStackView = {
    let sv = UIStackView(arrangedSubviews: self.dotViews)
    sv.spacing = 6
    sv.axis = .horizontal
    return sv
  }()
  
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
  
  func setupStyles() {}
  
  func setupLayouts() {
    [
      self.rightButton,
      self.dateLabel,
      self.contentLabel,
      self.dotStackView
    ].forEach {
      self.contentView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.dateLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.equalToSuperview().inset(26)
    }
    
    self.contentLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(26)
      make.top.equalTo(self.dotStackView.snp.bottom).offset(4.0)
    }
    
    self.rightButton.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.trailing.equalToSuperview().inset(26)
    }
    
    self.dotStackView.arrangedSubviews.forEach {
      $0.snp.makeConstraints { make in
        make.size.equalTo(7.0)
      }
    }
    
    self.dotStackView.snp.makeConstraints { make in
      make.leading.equalTo(self.dateLabel)
      make.top.equalTo(self.dateLabel.snp.bottom).offset(4.0)
    }
  }
  
  // MARK: - Configure
  
  /// 데이터를 받아 UI를 업데이트합니다.
  ///
  /// - Parameters:
  ///  - teamCalendar: 팀 일정
  func configure(_ teamCalendar: TeamCalendars) {
    self.dotViews.forEach { $0.isHidden = true }
    self.contentLabel.text = teamCalendar.title
    self.dateLabel.text = teamCalendar.startDate.toDateString(from: "yyyy-MM-dd", to: "M월 d일")
    self.dateLabel.text?.append(
      " ~ \(teamCalendar.endDate.toDateString(from: "yyyy-MM-dd", to: "M월 d일"))"
    )
    teamCalendar.targets.forEach {
      self.dotViews[$0.order].isHidden = false
    }
  }
}

// MARK: - Privates

private extension TeamCalendarCell {
  /// 유저의 색깔을 표시해주는 동그란 원 뷰를 생성합니다.
  ///
  /// - Parameters:
  ///  - color: 색깔을 표시해줍니다.
  func makeDotView(_ color: UIColor) -> UIView {
    let view = UIView()
    view.backgroundColor = color
    view.layer.cornerRadius = 3.5
    return view
  }
}

