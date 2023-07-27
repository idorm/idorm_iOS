//
//  CalendarMemberHeaderView.swift
//  idorm
//
//  Created by 김응철 on 7/14/23.
//

import UIKit

import SnapKit

protocol CalendarMemberHeaderDelegate: AnyObject {
  func didTapInviteRoommateButton()
  func didTapOptionButton()
}
  
/// 룸메이트 초대와 설정으로 바로갈 수 있는 헤더입니다.
final class CalendarMemberHeader: UICollectionReusableView, BaseView {
  
  // MARK: - Properties
  
  weak var delegate: CalendarMemberHeaderDelegate?
  
  // MARK: - UI Components
  
  /// `룸메이트 초대` 버튼
  lazy var inviteButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.attributedTitle = AttributedString(
      "룸메이트 초대",
      attributes: AttributeContainer([
        .font: UIFont.iDormFont(.bold, size: 12),
        .foregroundColor: UIColor.iDormColor(.iDormBlue)
      ])
    )
    config.baseBackgroundColor = .white
    config.background.cornerRadius = 18.0
    config.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 10, bottom: 3, trailing: 10)
    let button = UIButton(configuration: config)
    button.addTarget(self, action: #selector(self.didTapInviteButton), for: .touchUpInside)
    return button
  }()
  
  /// `옵션` 버튼
  private lazy var optionButton: UIButton = {
    let button = UIButton()
    button.setImage(.iDormIcon(.option), for: .normal)
    button.addTarget(self, action: #selector(self.didTapOptionButton), for: .touchUpInside)
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
  
  func setupStyles() {
    self.backgroundColor = .clear
  }
  
  func setupLayouts() {
    [
      self.inviteButton,
      self.optionButton
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.inviteButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(10)
      make.bottom.equalToSuperview().inset(54)
    }
    
    self.optionButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview()
      make.centerY.equalTo(self.inviteButton)
    }
  }
  
  // MARK: - Selectors
  
  @objc
  private func didTapOptionButton() {
    self.delegate?.didTapOptionButton()
  }
  
  @objc
  private func didTapInviteButton() {
    self.delegate?.didTapInviteRoommateButton()
  }
  
  // MARK: - Bind
  
  func configure(with members: [TeamMember]) {
    if members.count == 1 {
      self.inviteButton.isHidden = false
      self.optionButton.isHidden = true
    } else {
      self.inviteButton.isHidden = true
      self.optionButton.isHidden = false
    }
  }
}
