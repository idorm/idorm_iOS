//
//  BottomSheetVC.swift
//  idorm
//
//  Created by 김응철 on 2023/02/14.
//

import UIKit

import SnapKit
import PanModal

final class BottomSheetViewController: BaseViewController {
  
  // MARK: - PROPERTIES
  
  private let bottomSheet: BottomSheet
  
  private let dorm1Button = BottomSheetUtils.dormNumberButton(title: "인천대 1기숙사")
  private let dorm2Button = BottomSheetUtils.dormNumberButton(title: "인천대 2기숙사")
  private let dorm3Button = BottomSheetUtils.dormNumberButton(title: "인천대 3기숙사")
  private let reportButton = BottomSheetUtils.reportButton()
  private let deleteCommentButton = BottomSheetUtils.basicButton("댓글 삭제", image: UIImage(named: "trash"))
  private let deletePostButton = BottomSheetUtils.basicButton("게시글 삭제", image: UIImage(named: "trash"))
  private let shareButton = BottomSheetUtils.basicButton("공유하기", image: UIImage(named: "arrow_square"))
  private let editPostButton = BottomSheetUtils.basicButton("게시글 수정", image: UIImage(named: "pencil_square"))
  
  private let exitButton: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "xmark_black"), for: .normal)
    
    return btn
  }()
  
  var dormButtonCompletion: ((Dormitory) -> Void)?
  var reportButtonCompletion: (() -> Void)?
  var deleteButtonCompletion: (() -> Void)?
  var editButtonCompletion: (() -> Void)?
  var shareButtonCompletion: (() -> Void)?
  
  // MARK: - INITIALIZER
  
  init(_ bottomSheet: BottomSheet) {
    self.bottomSheet = bottomSheet
    super.init(nibName: nil, bundle: nil)
    setupSelectors()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - SETUP
  
  private func setupSelectors() {
    self.dorm1Button.addTarget(self, action: #selector(didTapDorm1Button), for: .touchUpInside)
    self.dorm1Button.addTarget(self, action: #selector(didTapDorm2Button), for: .touchUpInside)
    self.dorm1Button.addTarget(self, action: #selector(didTapDorm3Button), for: .touchUpInside)
    self.reportButton.addTarget(self, action: #selector(didTapReportButton), for: .touchUpInside)
    self.deletePostButton.addTarget(self, action: #selector(didTapDeletePostButton), for: .touchUpInside)
    self.deleteCommentButton.addTarget(self, action: #selector(didTapDeleteCommentButton), for: .touchUpInside)
    self.shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
    self.editPostButton.addTarget(self, action: #selector(didTapEditPostButton), for: .touchUpInside)
  }
  
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
        self.reportButton
      ].forEach {
        self.view.addSubview($0)
      }
    case .comment:
      self.view.addSubview(self.reportButton)
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
      
      self.reportButton.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(self.shareButton.snp.bottom)
      }
    case .comment:
      self.reportButton.snp.makeConstraints { make in
        make.leading.trailing.equalToSuperview().inset(24)
        make.top.equalTo(self.exitButton.snp.bottom).offset(8)
      }
    }
  }
  
  // MARK: - SELECTORS
  
  @objc
  private func didTapDorm1Button() {
    self.dormButtonCompletion?(.no1)
  }
  
  @objc
  private func didTapDorm2Button() {
    self.dormButtonCompletion?(.no2)
  }
  
  @objc
  private func didTapDorm3Button() {
    self.dormButtonCompletion?(.no3)
  }

  @objc
  private func didTapReportButton() {
    self.reportButtonCompletion?()
  }
  
  @objc
  private func didTapDeletePostButton() {
    self.deleteButtonCompletion?()
  }
  
  @objc
  private func didTapDeleteCommentButton() {
    self.deleteButtonCompletion?()
  }

  @objc
  private func didTapShareButton() {
    self.shareButtonCompletion?()
  }
  
  @objc
  private func didTapEditPostButton() {
    self.editButtonCompletion?()
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
}
