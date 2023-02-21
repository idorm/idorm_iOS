//
//  DormBottomSheet.swift
//  idorm
//
//  Created by 김응철 on 2023/01/14.
//

import UIKit

import SnapKit
import PanModal
import RxSwift
import RxCocoa

final class DormBottomSheet: BaseViewController {
  
  // MARK: - Properties
  
  private let cancelBtn: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "xmark_black"), for: .normal)
    
    return btn
  }()
  
  private let dorm1Btn = BottomSheetUtils.dormNumberButton("인천대 1기숙사")
  private let dorm2Btn = BottomSheetUtils.dormNumberButton("인천대 2기숙사")
  private let dorm3Btn = BottomSheetUtils.dormNumberButton("인천대 3기숙사")
  
  let didTapDormBtn = PublishSubject<Dormitory>()
  
  // MARK: - Setup
  
  override func setupStyles() {
    view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    [
      cancelBtn,
      dorm1Btn,
      dorm2Btn,
      dorm3Btn
    ].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    cancelBtn.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(10)
      make.trailing.equalToSuperview().inset(18)
    }
    
    dorm1Btn.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(cancelBtn.snp.bottom).offset(8)
    }
    
    dorm2Btn.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(dorm1Btn.snp.bottom)
    }
    
    dorm3Btn.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(dorm2Btn.snp.bottom)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    // 바텀시트 닫기
    cancelBtn.rx.tap
      .withUnretained(self)
      .bind { $0.0.dismiss(animated: true) }
      .disposed(by: disposeBag)
    
    // 기숙사 버튼 클릭
    dorm1Btn.rx.tap
      .map { Dormitory.no1 }
      .withUnretained(self)
      .bind { owner, dorm in
        owner.didTapDormBtn.onNext(dorm)
        owner.dismiss(animated: true)
      }
      .disposed(by: disposeBag)
    
    dorm2Btn.rx.tap
      .map { Dormitory.no2 }
      .withUnretained(self)
      .bind { owner, dorm in
        owner.didTapDormBtn.onNext(dorm)
        owner.dismiss(animated: true)
      }
      .disposed(by: disposeBag)

    dorm3Btn.rx.tap
      .map { Dormitory.no3 }
      .withUnretained(self)
      .bind { owner, dorm in
        owner.didTapDormBtn.onNext(dorm)
        owner.dismiss(animated: true)
      }
      .disposed(by: disposeBag)
  }
}

extension DormBottomSheet: PanModalPresentable {
  var panScrollable: UIScrollView? { nil }
  var shortFormHeight: PanModalHeight { .contentHeight(182) }
  var longFormHeight: PanModalHeight { .contentHeight(182) }
  var showDragIndicator: Bool { false }
  var cornerRadius: CGFloat { 24 }
}
