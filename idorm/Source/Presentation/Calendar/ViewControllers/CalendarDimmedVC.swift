//
//  CalendarDimmedVC.swift
//  idorm
//
//  Created by 김응철 on 7/26/23.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

protocol CalendarDimmedViewControllerDelegate: AnyObject {
  func didTapRegisterTeamScheduleButton()
  func didTapRegisterSleepOverButton()
}

/// 일정 등록을 클릭하면 `Dimmed` 처리가 되는 `VC`
final class CalendarDimmedViewController: BaseViewController {
  
  // MARK: - UI Components
  
  /// `일정 등록` 플로티 `UIButton`
  private let registerScheduleButton: UIButton = {
    let button = iDormButton("일정 등록", image: .iDormIcon(.pencil))
    button.cornerRadius = 47.0
    button.baseBackgroundColor = .iDormColor(.iDormBlue)
    button.baseForegroundColor = .white
    button.font = .iDormFont(.bold, size: 16.0)
    button.edgeInsets = .init(top: 10.0, leading: 18.0, bottom: 10.0, trailing: 18.0)
    button.isUserInteractionEnabled = false
    button.alpha = 0
    return button
  }()
  
  /// `우리방 일정` Floaty `UIButton`
  private let teamScheduleButton: UIButton = {
    let button = iDormButton("우리방 일정", image: nil)
    button.cornerRadius = 47.0
    button.baseForegroundColor = .iDormColor(.iDormBlue)
    button.baseBackgroundColor = .white
    button.font = .iDormFont(.bold, size: 16.0)
    button.edgeInsets = .init(top: 10.0, leading: 18.0, bottom: 10.0, trailing: 18.0)
    button.shadowOpacity = 0.13
    button.shadowRadius = 10.5
    button.shadowOffset = CGSize(width: 0, height: 8)
    button.alpha = 0
    return button
  }()
  
  /// `외박 일정` Floaty `UIButton`
  private let sleepOverButton: UIButton = {
    let button = iDormButton("외박 일정", image: nil)
    button.cornerRadius = 47.0
    button.baseForegroundColor = .iDormColor(.iDormBlue)
    button.baseBackgroundColor = .white
    button.font = .iDormFont(.bold, size: 16.0)
    button.edgeInsets = .init(top: 10.0, leading: 18.0, bottom: 10.0, trailing: 18.0)
    button.shadowOpacity = 0.13
    button.shadowRadius = 10.5
    button.shadowOffset = CGSize(width: 0, height: 8)
    button.alpha = 0
    return button
  }()
  
  // MARK: - Properties
  
  /// 레이아웃에 필요한 `Inset` 값의 정보를 추가적으로 알기 위한 `CGFloat`
  private let bottomInset: CGFloat
  
  weak var delegate: CalendarDimmedViewControllerDelegate?
  
  // MARK: - Initializer
  
  /// `CalendarDimmedVC`의 이니셜라이저입니다.
  ///
  /// - Parameters:
  ///  - bottomInset: 레이아웃에 필요한 `Inset` 값의 정보를 추가적으로 알기 위한 인자입니다.
  init(_ bottomInset: CGFloat) {
    self.bottomInset = bottomInset
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    UIView.animate(withDuration: 0.2) {
      self.view.backgroundColor = .black.withAlphaComponent(0.4)
      self.view.subviews.forEach {
        $0.alpha = 1
      }
    }
  }
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.registerScheduleButton,
      self.teamScheduleButton,
      self.sleepOverButton
    ].forEach { self.view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.registerScheduleButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview().inset(24.0 + self.bottomInset)
    }
    
    self.teamScheduleButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(self.registerScheduleButton.snp.top).offset(-12.0)
    }
    
    self.sleepOverButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(self.teamScheduleButton.snp.top).offset(-12.0)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    self.teamScheduleButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.dismiss(animated: false)
        owner.delegate?.didTapRegisterTeamScheduleButton()
      }
      .disposed(by: self.disposeBag)
    
    self.sleepOverButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.dismiss(animated: false)
        owner.delegate?.didTapRegisterSleepOverButton()
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.dismiss(animated: false)
  }
}
