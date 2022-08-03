//
//  CalendarPostViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/30.
//

import SnapKit
import UIKit
import RxSwift
import RxCocoa
import RSKPlaceholderTextView
import PanModal

class CalendarPostViewController: UIViewController {
  // MARK: - Properties
  lazy var titleTextField: UITextField = {
    let tf = UITextField()
    tf.attributedPlaceholder = NSAttributedString(
      string: "일정 등록",
      attributes: [
        NSAttributedString.Key.font: UIFont.init(name: Font.regular.rawValue, size: 24) ?? 0,
        NSAttributedString.Key.foregroundColor: UIColor.idorm_gray_300
    ])
    tf.font = .init(name: Font.regular.rawValue, size: 24)
    tf.textColor = .black
    tf.textAlignment = .left
    
    return tf
  }()
  
  lazy var withTextField: UITextField = {
    let tf = UITextField()
    tf.attributedPlaceholder = NSAttributedString(
      string: "함께하는 사람",
      attributes: [
        NSAttributedString.Key.font: UIFont.init(name: Font.regular.rawValue, size: 14) ?? 0,
        NSAttributedString.Key.foregroundColor: UIColor.idorm_gray_300
      ]
    )
    tf.textColor = .black
    tf.font = .init(name: Font.regular.rawValue, size: 14)
    
    return tf
  }()
  
  lazy var underlinedTextView: RSKPlaceholderTextView = {
    let tv = RSKPlaceholderTextView()
    tv.attributedPlaceholder = NSAttributedString(
      string: "메모",
      attributes: [
        NSAttributedString.Key.font: UIFont.init(name: Font.regular.rawValue, size: 14) ?? 0,
        NSAttributedString.Key.foregroundColor: UIColor.idorm_gray_300
      ]
    )
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 9
    tv.typingAttributes = [NSAttributedString.Key.paragraphStyle: paragraphStyle]
    tv.backgroundColor = .clear
    tv.textColor = .black
    tv.isScrollEnabled = false
    tv.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    tv.font = .init(name: Font.regular.rawValue, size: 14)
    tv.setContentHuggingPriority(.init(240), for: .vertical)
    
    return tv
  }()
  
  lazy var underlinedBackgroundView: UnderlinedBackGroundView = {
    let view = UnderlinedBackGroundView()
    view.backgroundColor = .white
    
    return view
  }()
  
  lazy var scrollView: UIScrollView = {
    let sv = UIScrollView()
    sv.isScrollEnabled = true
    
    return sv
  }()
  
  lazy var contentsView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    view.setContentHuggingPriority(.defaultLow, for: .vertical)
    
    return view
  }()
  
  lazy var startLabel = createBasicLabel(text: "시작")
  lazy var endLabel = createBasicLabel(text: "종료")
  
  lazy var startDateLabel = createBasicLabel(text: "nn월 nn일(목)")
  lazy var startTimeLabel = createBasicLabel(text: "오전 11시~")
  
  lazy var endDateLabel = createBasicLabel(text: "nn월 nn일(목)")
  lazy var endTimeLabel = createBasicLabel(text: "오전 11시~")
  
  lazy var humanImageView = UIImageView(image: UIImage(named: "human(Calendar)")?.withRenderingMode(.alwaysTemplate))
  lazy var pencilImageView = UIImageView(image: UIImage(named: "pencil(Calendar)")?.withRenderingMode(.alwaysTemplate))
  
  lazy var separatorLine1 = createBasicLine()
  lazy var separatorLine2 = createBasicLine()
  lazy var separatorLine3 = createBasicLine()
  
  lazy var startStack = UIStackView(arrangedSubviews: [ startDateLabel, startTimeLabel ])
  lazy var endStack = UIStackView(arrangedSubviews: [ endDateLabel, endTimeLabel ])
    
  let disposeBag = DisposeBag()
  
  let tapGesture = UITapGestureRecognizer()
  let startStackTapGesture = UITapGestureRecognizer()
  let endStackTapGesture = UITapGestureRecognizer()
  
  // MARK: - LifeCycle
  init() {
    super.init(nibName: nil, bundle: nil)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Bind
  private func bind() {
    /// 텍스트필드 실시간 이미지 반응
    withTextField.rx.text
      .orEmpty
      .map { $0 != "" }
      .bind(onNext: { [weak self] onChangedColor in
        if onChangedColor {
          self?.humanImageView.tintColor = .idorm_blue
        } else {
          self?.humanImageView.tintColor = .idorm_gray_400
        }
      })
      .disposed(by: disposeBag)
    
    /// 텍스트뷰 실시간 이미지 반응
    underlinedTextView.rx.text
      .orEmpty
      .map { $0 != "" }
      .bind(onNext: { [weak self] onChangedColor in
        if onChangedColor {
          self?.pencilImageView.tintColor = .idorm_blue
        } else {
          self?.pencilImageView.tintColor = .idorm_gray_400
        }
      })
      .disposed(by: disposeBag)
    
    /// 텍스트뷰 글자수 제한
    underlinedTextView.rx.text
      .orEmpty
      .scan("") { pervious, new -> String in
        if new.count >= 180 {
          return pervious
        } else {
          return new
        }
      }
      .asDriver(onErrorJustReturn: "")
      .drive(underlinedTextView.rx.text)
      .disposed(by: disposeBag)
    
    /// 백그라운드 터치 시 키보드 내리기
    tapGesture.rx.event
      .bind(onNext: { [weak self] _ in
        self?.view.endEditing(true)
      })
      .disposed(by: disposeBag)
    
    /// 날짜 선택 시 캘린더 설정 하단 화면 출현
    Observable.merge(startStackTapGesture.rx.event.asObservable(), endStackTapGesture.rx.event.asObservable())
      .bind(onNext: { [weak self] _ in
        let setCalendarVC = SetCalendarTabmanController()
        self?.presentPanModal(setCalendarVC)
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .white
    startTimeLabel.textColor = .idorm_gray_300
    endTimeLabel.textColor = .idorm_gray_300
    
    contentsView.addGestureRecognizer(tapGesture)
    endStack.addGestureRecognizer(endStackTapGesture)
    startStack.addGestureRecognizer(startStackTapGesture)
    
    startStack.axis = .vertical
    endStack.axis = .vertical
    let withStack = UIStackView(arrangedSubviews: [ humanImageView, withTextField ])
    humanImageView.setContentHuggingPriority(.init(rawValue: 251), for: .horizontal)
    withStack.spacing = 12
    
    view.addSubview(scrollView)
    scrollView.addSubview(contentsView)
    
    scrollView.snp.makeConstraints { make in
      make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
      make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
    }
    
    contentsView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview().inset(16)
      make.width.equalTo(view.frame.width)
    }
    
    [ titleTextField, startLabel, endLabel, startStack, endStack, separatorLine1, withStack, separatorLine2, pencilImageView, underlinedBackgroundView, underlinedTextView, separatorLine3 ]
      .forEach { contentsView.addSubview($0) }

    titleTextField.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview().inset(24)
    }
    
    startLabel.snp.makeConstraints { make in
      make.top.equalTo(titleTextField.snp.bottom).offset(24)
      make.leading.equalToSuperview().inset(24)
    }
    
    endLabel.snp.makeConstraints { make in
      make.top.equalTo(startLabel.snp.bottom).offset(43)
      make.leading.equalToSuperview().inset(24)
    }
    
    startStack.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(24)
      make.top.equalTo(startLabel.snp.top)
    }
    
    endStack.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(24)
      make.top.equalTo(endLabel.snp.top)
    }
    
    separatorLine1.snp.makeConstraints { make in
      make.top.equalTo(endStack.snp.bottom).offset(54)
      make.leading.trailing.equalToSuperview().inset(24)
      make.height.equalTo(1)
    }
    
    withStack.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(separatorLine1.snp.bottom).offset(14)
    }
    
    separatorLine2.snp.makeConstraints { make in
      make.top.equalTo(withStack.snp.bottom).offset(14)
      make.leading.trailing.equalToSuperview().inset(24)
      make.height.equalTo(1)
    }
    
    pencilImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(separatorLine2.snp.bottom).offset(14)
    }
    
    underlinedBackgroundView.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(58)
      make.leading.equalTo(pencilImageView.snp.trailing).offset(8)
      make.top.equalTo(separatorLine2.snp.bottom).offset(8)
      make.height.equalTo(250)
    }
    
    underlinedTextView.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(58)
      make.leading.equalTo(pencilImageView.snp.trailing).offset(8)
      make.top.equalTo(separatorLine2.snp.bottom).offset(8)
      make.bottom.equalTo(underlinedBackgroundView.snp.bottom)
    }
    
    separatorLine3.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(underlinedBackgroundView.snp.bottom).offset(14)
      make.bottom.equalToSuperview()
      make.height.equalTo(1)
    }
    scrollView.updateContentSize()
  }
}

// MARK: - Create Properties Methods
extension CalendarPostViewController {
  func createBasicLabel(text: String) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = .init(name: Font.regular.rawValue, size: 14)
    label.textColor = .black
    
    return label
  }
  
  func createBasicLine() -> UIView {
    let line = UIView()
    line.backgroundColor = .idorm_gray_200
    
    return line
  }
}
