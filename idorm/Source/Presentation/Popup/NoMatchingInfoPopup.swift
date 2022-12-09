//
//  NoMatchingInfoAlertVC.swift
//  idorm
//
//  Created by 김응철 on 2022/11/27.
//

import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa

final class NoMatchingInfoPopup: BaseViewController {
  
  // MARK: - Properties
  
  private let titleLabel = UILabel().then {
    $0.text = "매칭 이미지가 아직 없어요. 😅"
    $0.textColor = .black
    $0.font = .init(name: MyFonts.medium.rawValue, size: 16)
  }
  
  private let xmarkButton = UIButton().then {
    $0.setImage(#imageLiteral(resourceName: "Xmark_Black"), for: .normal)
  }
  
  private let mainLabel = UILabel().then {
    $0.text = """
              룸메이트 매칭을 위해
              우선 매칭 이미지를 만들어 주세요.
              """
    $0.numberOfLines = 2
    $0.textAlignment = .center
    $0.textColor = .idorm_gray_400
    $0.font = .init(name: MyFonts.regular.rawValue, size: 14)
  }
  
  private let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 12
  }
  
  let makeButton = idormButton("프로필 이미지 만들기")
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    view.backgroundColor = .black.withAlphaComponent(0.5)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    view.addSubview(containerView)
    [titleLabel, xmarkButton, mainLabel, makeButton]
      .forEach { containerView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    containerView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.centerY.equalToSuperview()
      make.height.equalTo(230)
    }
    
    titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalToSuperview().inset(20)
    }
    
    xmarkButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(24)
      make.centerY.equalTo(titleLabel)
    }
    
    mainLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalTo(titleLabel.snp.bottom).offset(36)
    }
    
    makeButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.bottom.equalToSuperview().inset(20)
      make.height.equalTo(50)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    xmarkButton.rx.tap
      .withUnretained(self)
      .bind(onNext: { $0.0.dismiss(animated: false) })
      .disposed(by: disposeBag)
  }
}
