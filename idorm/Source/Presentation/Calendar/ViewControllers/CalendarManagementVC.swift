//
//  CalendarManagementVC.swift
//  idorm
//
//  Created by 김응철 on 7/26/23.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import RxGesture

/// `일정 등록`이나 `일정 수정`을 위한 페이지입니다.
final class CalendarManagementViewController: BaseViewController, View {
  
  // MARK: - UI Components
  
  /// 화면 전체적으로 감쌀 `UIScrollView`
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.isScrollEnabled = true
    return scrollView
  }()
  
  /// `scrollView`의 `UIView`
  private let contentView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    return view
  }()
  
  /// `우리방 일정 이름`인 `UITextField`
  private let titleTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "우리방 일정 이름"
    textField.attributedPlaceholder = NSAttributedString(
      string: "우리방 일정 이름",
      attributes: [
        .font: UIFont.iDormFont(.medium, size: 24.0),
        .foregroundColor: UIColor.iDormColor(.iDormGray300)
      ]
    )
    textField.textColor = .black
    textField.font = .iDormFont(.medium, size: 24.0)
    return textField
  }()
  
  /// `시작`이 적혀있는 `UILabel`
  private let startLabel: UILabel = {
    let label = UILabel()
    label.text = "시작"
    label.textColor = .black
    label.font = .iDormFont(.medium, size: 14.0)
    return label
  }()
  
  /// `종료`가 적혀있는 `UILabel`
  private let endLabel: UILabel = {
    let label = UILabel()
    label.text = "종료"
    label.textColor = .black
    label.font = .iDormFont(.medium, size: 14.0)
    return label
  }()
  
  /// 시작 날짜 및 시간이 적혀있는 `UIButton`
  private let startDateButton: iDormButton = {
    let button = iDormButton("", image: nil)
    button.font = .iDormFont(.medium, size: 14.0)
    button.baseForegroundColor = .black
    button.titlePadding = 4.0
    button.subTitleFont = .iDormFont(.medium, size: 14.0)
    button.subTitleColor = .iDormColor(.iDormGray300)
    return button
  }()
  
  /// 종료 날짜 및 시간이 적혀있는 `UIButton`
  private let endDateButton: iDormButton = {
    let button = iDormButton("", image: nil)
    button.font = .iDormFont(.medium, size: 14.0)
    button.baseForegroundColor = .black
    button.titlePadding = 4.0
    button.subTitleFont = .iDormFont(.medium, size: 14.0)
    button.subTitleColor = .iDormColor(.iDormGray300)
    return button
  }()
  
  /// `일정 참여자`가 적혀있는 `UILabel`
  private let participantsLabel: UILabel = {
    let label = UILabel()
    label.text = "일정 참여자"
    label.textColor = .black
    label.font = .iDormFont(.medium, size: 14.0)
    return label
  }()
  
  /// `ic_human`인 `UIImageView`
  private let participantImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .iDormIcon(.human)
    return imageView
  }()
  
  /// `ic_pencil2`인 `UIImageView`
  private let memoImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .iDormIcon(.pencil2)
    return imageView
  }()
  
  /// `일정 참여자` 섹션과 `메모` 섹션을 나눠주는 한 줄의 `UIView`
  private let separatorLineView: UIView = {
    let view = UIView()
    view.backgroundColor = .iDormColor(.iDormGray200)
    return view
  }()
  
  /// 여러 `Line`이 존재하는 `UITextView`
  private let memoTextView: CalendarMemoTextView = {
    let textView = CalendarMemoTextView()
    return textView
  }()
  
  /// `일정 삭제`, `완료` 버튼이 들어있는 `iDormBottomView`
  private lazy var bottomView: iDormBottomView = {
    let view = iDormBottomView(
      leftButton: .init("일정 삭제", image: nil),
      rightButton: .init("완료", image: nil),
      bottomInset: self.view.safeAreaInsets.bottom
    )
    return view
  }()
  
  /// `iDormBottomView`와 `iDormMemoTextView`의 섹션을 나눠주는 `UIView`
  private let lastSeparatorLineView: UIView = {
    let view = UIView()
    view.backgroundColor = .iDormColor(.iDormGray200)
    return view
  }()
  
  // MARK: - Properties
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.view.addSubview(self.scrollView)
    self.view.addSubview(self.bottomView)
    self.scrollView.addSubview(self.contentView)
    
    [
      self.titleTextField,
      self.startLabel, self.startDateButton,
      self.endLabel, self.endDateButton,
      self.participantsLabel, self.participantImageView,
      self.separatorLineView,
      self.memoImageView, self.memoTextView,
      self.lastSeparatorLineView
    ].forEach {
      self.contentView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.bottomView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
    }
    
    self.scrollView.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalTo(self.bottomView.snp.top)
    }
    
    self.contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalTo(self.view.frame.width)
    }
    
    self.titleTextField.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(24.0)
      make.leading.equalToSuperview().inset(24.0)
    }
    
    self.startLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24.0)
      make.top.equalTo(self.titleTextField.snp.bottom).offset(30.0)
      make.height.equalTo(21.0)
    }
    
    self.startDateButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(24.0)
      make.top.equalTo(self.startLabel)
    }
    
    self.endLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24.0)
      make.top.equalTo(self.startLabel.snp.bottom).offset(43.0)
      make.height.equalTo(21.0)
    }
    
    self.endDateButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(24.0)
      make.top.equalTo(self.endLabel)
    }
    
    self.participantsLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24.0)
      make.top.equalTo(self.endLabel.snp.bottom).offset(45.0)
      make.height.equalTo(21.0)
    }
    
    self.participantImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24.0)
      make.top.equalTo(self.participantsLabel.snp.bottom).offset(44.0)
      make.height.equalTo(24.0)
    }
    
    self.separatorLineView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
      make.top.equalTo(self.participantImageView.snp.bottom).offset(44.0)
      make.height.equalTo(1.0)
    }
    
    self.memoImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24.0)
      make.top.equalTo(self.separatorLineView.snp.bottom).offset(14.0)
      make.height.equalTo(24.0)
    }
    
    self.memoTextView.snp.makeConstraints { make in
      make.top.equalTo(self.separatorLineView.snp.bottom)
      make.leading.equalTo(self.memoImageView.snp.trailing).offset(8.0)
      make.trailing.equalToSuperview().inset(53.0)
      make.height.equalTo(292.0)
    }
    
    self.lastSeparatorLineView.snp.makeConstraints { make in
      make.top.equalTo(self.memoTextView.snp.bottom).offset(27.0)
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
      make.height.equalTo(1.0)
      make.bottom.equalToSuperview().inset(24.0)
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: CalendarManagementViewReactor) {
    // Action
    self.scrollView.rx.tapGesture()
      .when(.recognized)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, gesture in
        owner.view.endEditing(true)
      }
      .disposed(by: self.disposeBag)
    
    // State
  }
}
