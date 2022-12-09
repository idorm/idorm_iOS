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

final class NoMatchingInfoPopup_Initial: BaseViewController {
  
  // MARK: - Properties
  
  let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 12.0
  }
  
  let titleLabel = UILabel().then {
    $0.text = "i dorm에 처음 오셨네요!🙂"
    $0.textColor = .black
    $0.font = .init(name: MyFonts.medium.rawValue, size: 16)
  }
  
  let descriptionLabel = UILabel().then {
    $0.text = """
    룸메이트 매칭을 위해
    우선 프로필 이미지를 만들어 주세요.
    """
    $0.textColor = .black
    $0.font = .init(name: MyFonts.regular.rawValue, size: 14)
    $0.textAlignment = .center
    $0.numberOfLines = 2
  }
  
  let xmarkButton = UIButton().then {
    $0.setImage(UIImage(named: "Xmark_Black"), for: .normal)
  }
  
  let confirmButton = idormButton("프로필 이미지 만들기")
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    view.backgroundColor = .black.withAlphaComponent(0.5)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    view.addSubview(containerView)
    
    [titleLabel, descriptionLabel, xmarkButton, confirmButton]
      .forEach { containerView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    containerView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.equalTo(view.frame.width - 48)
      make.height.equalTo(230)
    }
    
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(20)
      make.leading.equalToSuperview().inset(24)
    }
    
    xmarkButton.snp.makeConstraints { make in
      make.centerY.equalTo(titleLabel)
      make.trailing.equalToSuperview().inset(24)
    }
    
    descriptionLabel.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(-8)
    }
    
    confirmButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.height.equalTo(50)
      make.bottom.equalToSuperview().inset(20)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // 닫기 버튼 클릭 이벤트
    xmarkButton.rx.tap
      .bind(onNext: { [weak self] in
        self?.dismiss(animated: false)
      })
      .disposed(by: disposeBag)
    
    // 프로필 이미지 만들기 버튼 클릭 이벤트
    confirmButton.rx.tap
      .bind(onNext: {
        
      })
      .disposed(by: disposeBag)
  }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct ViewControllerPreView: PreviewProvider {
  static var previews: some View {
    NoMatchingInfoPopup_Initial().toPreview()
  }
}
#endif

