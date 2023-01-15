//
//  MyRoommaateBottomSheet.swift
//  idorm
//
//  Created by 김응철 on 2022/12/21.
//

import UIKit

import RxSwift
import RxCocoa
import PanModal
import SnapKit
import Then

final class MyRoommaateBottomSheet: BaseViewController {
  
  // MARK: - Properties

  var deleteButton: UIButton!
  let chatButton = BottomSheetUtils.basicButton("룸메이트와 채팅하기", image: #imageLiteral(resourceName: "speechBubble_black"))
  let reportButton = BottomSheetUtils.reportButton()
  private let xmarkButton = BottomSheetUtils.button(#imageLiteral(resourceName: "xmark_black"))
  private let indicator = UIActivityIndicatorView().then { $0.color = .gray }
  
  private let roommate: MyPageEnumerations.Roommate
  
  // MARK: - LifeCycle
  
  init(_ roommate: MyPageEnumerations.Roommate) {
    self.roommate = roommate
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup

  override func setupStyles() {
    view.backgroundColor = .white
    var button: UIButton
    switch roommate {
    case .dislike:
      button = BottomSheetUtils.basicButton("싫어요한 룸메에서 삭제", image: #imageLiteral(resourceName: "trash"))
    case .like:
      button = BottomSheetUtils.basicButton("좋아요한 룸메에서 삭제", image: #imageLiteral(resourceName: "trash"))
    }
    self.deleteButton = button
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [xmarkButton, deleteButton, reportButton, chatButton, indicator]
      .forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    xmarkButton.snp.makeConstraints { make in
      make.top.trailing.equalToSuperview().inset(16)
    }
    
    chatButton.snp.makeConstraints { make in
      make.top.equalTo(xmarkButton.snp.bottom).offset(4)
      make.leading.trailing.equalToSuperview().inset(22)
    }
    
    deleteButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(22)
      make.top.equalTo(chatButton.snp.bottom).offset(4)
    }
    
    reportButton.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(22)
      make.top.equalTo(deleteButton.snp.bottom).offset(4)
    }
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    
    xmarkButton.rx.tap
      .withUnretained(self)
      .bind { $0.0.dismiss(animated: true) }
      .disposed(by: disposeBag)
    
    reportButton.rx.tap
      .withUnretained(self)
      .bind { $0.0.dismiss(animated: true) }
      .disposed(by: disposeBag)
  }
}

// MARK: - PanModal Setup

extension MyRoommaateBottomSheet: PanModalPresentable {
  var panScrollable: UIScrollView? { return nil }
  
  var shortFormHeight: PanModalHeight {
    return PanModalHeight.contentHeight(CGFloat(208))
  }
  
  var longFormHeight: PanModalHeight {
    return PanModalHeight.contentHeight(CGFloat(208))
  }
}
