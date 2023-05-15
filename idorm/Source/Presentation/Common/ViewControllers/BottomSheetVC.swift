//
//  BottomSheetVC.swift
//  idorm
//
//  Created by 김응철 on 2023/02/14.
//

import UIKit

import SnapKit
import PanModal
import RxSwift
import RxCocoa

final class BottomSheetViewController: BaseViewController {
  
  enum BottomSheetButtonType {
    case dorm(Dormitory)
    case report
    case deleteComment
    case deletePost
    case share
    case editPost
  }
  
  // MARK: - UI COMPONENTS
    
  private let dorm1Button = BottomSheetUtils.dormNumberButton("인천대 1기숙사")
  private let dorm2Button = BottomSheetUtils.dormNumberButton("인천대 2기숙사")
  private let dorm3Button = BottomSheetUtils.dormNumberButton("인천대 3기숙사")
  private let reportButton = BottomSheetUtils.reportButton()
  private let deleteCommentButton = BottomSheetUtils.basicButton("댓글 삭제", imageName: "trash")
  private let deletePostButton = BottomSheetUtils.basicButton("게시글 삭제", imageName: "trash")
  private let shareButton = BottomSheetUtils.basicButton("공유하기", imageName: "arrow_square")
  private let editPostButton = BottomSheetUtils.basicButton("게시글 수정", imageName: "pencil_square")
  private let exitButton = UIFactory.button("xmark_black")
  private let blockButton = BottomSheetUtils.basicButton("사용자 차단", imageName: "circle_cancel")
  
  // MARK: - PROPERTIES
  
  private let bottomSheet: BottomSheet
  let buttonDidTap = PublishSubject<BottomSheetButtonType>()
  
  // MARK: - INITIALIZER
  
  init(_ bottomSheet: BottomSheet) {
    self.bottomSheet = bottomSheet
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - SETUP

  override func setupStyles() {
    self.view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    self.view.addSubview(self.exitButton)
    
    switch self.bottomSheet {
    case .selectDorm:
      [
        self.dorm1Button,
        self.dorm2Button,
        self.dorm3Button
      ].forEach {
        self.view.addSubview($0)
      }
    case .myPost:
      [
        self.shareButton,
        self.deletePostButton,
        self.editPostButton,
        self.reportButton
      ].forEach {
        self.view.addSubview($0)
      }
    case .myComment:
      [
        self.deleteCommentButton,
        self.reportButton
      ].forEach {
        self.view.addSubview($0)
      }
    case .post:
      [
        self.shareButton,
        self.blockButton,
        self.reportButton
      ].forEach {
        self.view.addSubview($0)
      }
    case .comment:
      [
        self.blockButton,
        self.reportButton
      ].forEach {
        self.view.addSubview($0)
      }
    }
  }
  
  override func setupConstraints() {
    self.exitButton.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(10)
      make.trailing.equalToSuperview().inset(18)
    }
    
    switch self.bottomSheet {
    case .selectDorm:
      self.dorm1Button.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(self.exitButton.snp.bottom).offset(8)
      }
      
      self.dorm2Button.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(self.dorm1Button.snp.bottom)
      }
      
      self.dorm3Button.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(self.dorm2Button.snp.bottom)
      }
    case .myPost:
      self.shareButton.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(self.exitButton.snp.bottom).offset(8)
      }
      
      self.deletePostButton.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(self.shareButton.snp.bottom)
      }
      
      self.editPostButton.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(self.deletePostButton.snp.bottom)
      }
      
      self.reportButton.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(self.editPostButton.snp.bottom)
      }
    case .myComment:
      self.deleteCommentButton.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(self.exitButton.snp.bottom).offset(8)
      }

      self.reportButton.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(self.deleteCommentButton.snp.bottom)
      }
    case .post:
      self.shareButton.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(self.exitButton.snp.bottom).offset(8)
      }
      
      self.blockButton.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(self.shareButton.snp.bottom)
      }
      
      self.reportButton.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(self.blockButton.snp.bottom)
      }
    case .comment:
      self.blockButton.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(self.exitButton.snp.bottom).offset(8)
      }
      
      self.reportButton.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(self.blockButton.snp.bottom)
      }
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    
    // 종료 버튼 -> 화면 종료
    self.exitButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.dismiss(animated: true)
      }
      .disposed(by: self.disposeBag)
    
    // 기숙사 버튼
    self.dorm1Button.rx.tap
      .map { BottomSheetButtonType.dorm(.no1) }
      .withUnretained(self)
      .do { $0.0.dismiss(animated: true) }
      .map { $0.1 }
      .bind(to: self.buttonDidTap)
      .disposed(by: self.disposeBag)
    
    self.dorm2Button.rx.tap
      .map { BottomSheetButtonType.dorm(.no2) }
      .withUnretained(self)
      .do { $0.0.dismiss(animated: true) }
      .map { $0.1 }
      .bind(to: self.buttonDidTap)
      .disposed(by: self.disposeBag)

    self.dorm3Button.rx.tap
      .map { BottomSheetButtonType.dorm(.no3) }
      .withUnretained(self)
      .do { $0.0.dismiss(animated: true) }
      .map { $0.1 }
      .bind(to: self.buttonDidTap)
      .disposed(by: self.disposeBag)
    
    // 신고 버튼
    self.reportButton.rx.tap
      .map { BottomSheetButtonType.report }
      .withUnretained(self)
      .do { $0.0.dismiss(animated: true) }
      .map { $0.1 }
      .bind(to: self.buttonDidTap)
      .disposed(by: self.disposeBag)
    
    // 댓글 삭제
    self.deleteCommentButton.rx.tap
      .map { BottomSheetButtonType.deleteComment }
      .withUnretained(self)
      .do { $0.0.dismiss(animated: true) }
      .map { $0.1 }
      .bind(to: self.buttonDidTap)
      .disposed(by: self.disposeBag)

    // 게시글 삭제
    self.deletePostButton.rx.tap
      .map { BottomSheetButtonType.deletePost }
      .withUnretained(self)
      .do { $0.0.dismiss(animated: true) }
      .map { $0.1 }
      .bind(to: self.buttonDidTap)
      .disposed(by: self.disposeBag)
    
    // 게시글 수정
    self.editPostButton.rx.tap
      .map { BottomSheetButtonType.editPost }
      .withUnretained(self)
      .do { $0.0.dismiss(animated: true) }
      .map { $0.1 }
      .bind(to: self.buttonDidTap)
      .disposed(by: self.disposeBag)
    
    // 사용자 차단
    self.blockButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.dismiss(animated: true)
      }
      .disposed(by: disposeBag)
  }
}

extension BottomSheetViewController: PanModalPresentable {
  var panScrollable: UIScrollView? { nil }
  
  var shortFormHeight: PanModalHeight {
    PanModalHeight.contentHeight(self.bottomSheet.height)
    
  }
  
  var longFormHeight: PanModalHeight {
    PanModalHeight.contentHeight(self.bottomSheet.height)
  }
  
  var showDragIndicator: Bool { false }
}
