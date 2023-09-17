//
//  CalendarSleepoverListCell.swift
//  idorm
//
//  Created by 김응철 on 8/21/23.
//

import UIKit

import SnapKit

final class CalendarSleepoverListCell: UICollectionViewCell, BaseViewProtocol {
  
  // MARK: - UI Components
  
  private let dateLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.medium, size: 12.0)
    label.textColor = .black
    return label
  }()
  
  private let contentLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.regular, size: 12.0)
    label.textColor = .iDormColor(.iDormGray300)
    label.text = "외박"
    return label
  }()
  
  private let rightArrowButton: UIButton = {
    let button = UIButton()
    button.setImage(.iDormIcon(.right), for: .normal)
    button.isUserInteractionEnabled = false
    return button
  }()
  
  private let trashcanButton: UIButton = {
    let button = UIButton()
    let image: UIImage? = .iDormIcon(.trashcan)?
      .withTintColor(.iDormColor(.iDormGray400))
      .resize(newSize: 16.0)
    button.setImage(image, for: .normal)
    button.isUserInteractionEnabled = false
    return button
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
      self.dateLabel,
      self.contentLabel,
      self.rightArrowButton,
      self.trashcanButton
    ].forEach {
      self.contentView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.dateLabel.snp.makeConstraints { make in
      make.top.leading.equalToSuperview()
    }
    
    self.contentLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.top.equalTo(self.dateLabel.snp.bottom).offset(4.0)
    }
    
    self.rightArrowButton.snp.makeConstraints { make in
      make.top.trailing.equalToSuperview()
    }
    
    self.trashcanButton.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.trailing.equalToSuperview().inset(4.0)
    }
  }
  
  // MARK: - Configure
  
  func configure(
    with teamCalendar: TeamCalendar,
    isEditing: Bool,
    isMyOwnCalendar: Bool
  ) {
    self.dateLabel.text = teamCalendar.startDate
    self.dateLabel.text?.append(" ~ \(teamCalendar.endDate)")
    self.rightArrowButton.isHidden = true
    self.trashcanButton.isHidden = true
    if isMyOwnCalendar {
      if isEditing {
        self.rightArrowButton.isHidden = true
        self.trashcanButton.isHidden = false
      } else {
        self.rightArrowButton.isHidden = false
        self.trashcanButton.isHidden = true
      }
    }
  }
}
