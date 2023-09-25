//
//  MatchingPopupView.swift
//  idorm
//
//  Created by 김응철 on 2022/10/03.
//

import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa

final class WelcomePopupViewController: BaseViewController {
  
  // MARK: - UI Components
  
  /// 중앙에 있는 콘테이너 역할을 하는 `UIView`
  private let containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    return view
  }()

  /// `i dorm에 처음 오셨네요!🙂`가 적혀있는 `UILabel`
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.text = "i dorm에 처음 오셨네요!🙂"
    label.textColor = .black
    label.font = .iDormFont(.medium, size: 16.0)
    return label
  }()
  
  /// 부연설명의 `UILabel`
  let subtitleLabel: UILabel = {
    let label = UILabel()
    label.text = """
    룸메이트 매칭을 위해
    우선 프로필 이미지를 만들어 주세요.
    """
    label.textColor = .black
    label.font = .iDormFont(.regular, size: 14.0)
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  /// `ic_xmark`인 `UIButton`
  private let cancelButton = iDormButton(image: .iDormIcon(.cancel))
  
  /// `프로필 이미지 만들기`가 적혀있는 `UIButton`
  private let continueButton: iDormButton = {
    let button = iDormButton("프로필 이미지 만들기")
    button.font = .iDormFont(.medium, size: 14.0)
    button.cornerRadius = 10.0
    button.baseBackgroundColor = .iDormColor(.iDormBlue)
    button.baseForegroundColor = .white
    return button
  }()
  
  // MARK: - Properties
  
  var buttonHandler: (() -> Void)?
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.view.backgroundColor = .black.withAlphaComponent(0.5)
  }
  
  override func setupLayouts() {
    super.setupLayouts()

    self.view.addSubview(containerView)
    [
      self.titleLabel,
      self.subtitleLabel,
      self.cancelButton,
      self.continueButton
    ].forEach {
      self.containerView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.containerView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
      make.height.equalTo(230.0)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(20.0)
      make.leading.equalToSuperview().inset(24.0)
    }
    
    self.cancelButton.snp.makeConstraints { make in
      make.centerY.equalTo(self.titleLabel)
      make.trailing.equalToSuperview().inset(24.0)
    }
    
    self.subtitleLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(-8.0)
    }
    
    self.continueButton.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(24)
      make.height.equalTo(50.0)
      make.bottom.equalToSuperview().inset(20.0)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    self.cancelButton.rx.tap.asDriver()
      .drive(with: self) { owner, _ in
        owner.dismiss(animated: false)
      }
      .disposed(by: self.disposeBag)
    
    self.continueButton.rx.tap.asDriver()
      .drive(with: self) { owner, _ in
        owner.dismiss(animated: false)
        owner.buttonHandler?()
      }
      .disposed(by: self.disposeBag)
  }
}
