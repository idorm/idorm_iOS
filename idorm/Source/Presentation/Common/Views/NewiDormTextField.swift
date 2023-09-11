//
//  NewiDormTextField.swift
//  idorm
//
//  Created by 김응철 on 9/5/23.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class NewiDormTextField: UIView, BaseView {
  
  enum iDormTextFieldType {
    case withBorderLine
    case login
    case custom
  }
  
  // MARK: - UI Components
  
  /// 메인이 되는 `UITextField`
  private let textField: UITextField = {
    let textField = UITextField()
    return textField
  }()
  
  /// ic_openedEye인 `UIButton`
  private let openedEyeButton: iDormButton = {
    let button = iDormButton("", image: .iDormIcon(.openedEye))
    button.isHidden = true
    return button
  }()
  
  /// ic_closedEye인 `UIButton`
  private let closedEyeButton: iDormButton = {
    let button = iDormButton("", image: .iDormIcon(.closedEye))
    button.isHidden = true
    return button
  }()
  
  /// ic_checkCircle인 `UIImageView`
  private let checkCircleImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .iDormIcon(.checkCircle)
    imageView.isHidden = true
    return imageView
  }()
  
  // MARK: - Properties
  
  private var disposeBag = DisposeBag()
  
  /// 텍스트 필드 `PlaceHolder`의 `NSAttributedString`
  private var placeHolderAttributedString: NSAttributedString {
    return NSAttributedString(
      string: self.placeHolder,
      attributes: [
        .font: self.placeHolderFont,
        .foregroundColor: self.placeHolderColor
      ]
    )
  }
  
  /// 현재 가지고 있는 `iDormTextFieldType`
  private let iDormTextFieldType: iDormTextFieldType
  
  /// 높이 값을 업데이트 하는 `Constarint`
  private var heightOfTextFieldConstraint: Constraint?
  
  /// 텍스트 필드의 기본 `폰트`
  var font: UIFont = .iDormFont(.medium, size: 14.0) {
    willSet { self.textField.font = newValue }
  }
  
  /// 텍스트 필드의 인풋 `String`
  var text: String? {
    get { return self.textField.text }
    set { self.textField.text = newValue }
  }
  
  /// 텍스트 필드의 기본 `색상`
  var textColor: UIColor = .black {
    willSet { self.textField.textColor = newValue }
  }
  
  /// 텍스트 필드의 `PlaceHolder`
  var placeHolder: String = "" {
    didSet { self.textField.attributedPlaceholder = self.placeHolderAttributedString }
  }
  
  /// 텍스트 필드의 `PlaceHolder`의 폰트
  var placeHolderFont: UIFont = .iDormFont(.medium, size: 14.0) {
    willSet { self.textField.attributedPlaceholder = self.placeHolderAttributedString }
  }
  
  /// 텍스트 필드의 `PlaceHolder` 색상
  var placeHolderColor: UIColor = .iDormColor(.iDormGray300) {
    willSet { self.textField.attributedPlaceholder = self.placeHolderAttributedString }
  }
  
  /// 텍스트 필드의 `CornerRadius`
  var cornerRadius: CGFloat = 0.0 {
    willSet { self.textField.layer.cornerRadius = newValue }
  }
  
  /// 텍스트 필드의 `BorderColor`
  var borderColor: UIColor = .clear {
    willSet { self.textField.layer.borderColor = newValue.cgColor }
  }
  
  /// 텍스트 필드의 `BorderWidth`
  var borderWidth: CGFloat = 0.0 {
    willSet { self.textField.layer.borderWidth = newValue }
  }
  
  /// 텍스트 필드의 백그라운드 `UIColor`
  var baseBackgroundColor: UIColor = .white {
    willSet { self.textField.backgroundColor = newValue }
  }
  
  /// 텍스트 필드의 키보드 타입
  var keyboardType: UIKeyboardType = .default {
    willSet { self.textField.keyboardType = newValue }
  }
  
  /// 텍스트 필드의 높이 `CGFloat`
  var heightOfTextField: CGFloat = 54.0 {
    willSet { self.heightOfTextFieldConstraint?.update(offset: newValue) }
  }
  
  /// 텍스트 필드 왼쪽 Padding `CGFloat`
  var leftPadding: CGFloat = 16.0 {
    willSet { self.textField.addLeftPadding(newValue) }
  }
  
  /// 텍스트 필드의 `isSecureTextEntry`
  var isSecureTextEntry: Bool = false {
    willSet { self.textField.isSecureTextEntry = newValue }
  }
  
  /// 텍스트 필드의 `isEnabled`
  var isEnabled: Bool = true {
    willSet { self.textField.isEnabled = newValue }
  }
  
  /// 텍스트 필드의 `ValidationType`
  var validationType: ValidationType?
  
  // MARK: - Initializer
  
  init(type: iDormTextFieldType) {
    self.iDormTextFieldType = type
    super.init(frame: .zero)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  func setupStyles() {
    self.font = .iDormFont(.medium, size: 14.0)
    self.textColor = .iDormColor(.iDormGray300)
    self.placeHolderFont = .iDormFont(.medium, size: 14.0)
    switch self.iDormTextFieldType {
      
    case .login:
      self.baseBackgroundColor = .iDormColor(.iDormGray100)
      self.placeHolderColor = .iDormColor(.iDormGray300)
      self.cornerRadius = 12.0
      self.heightOfTextField = 54.0
      self.leftPadding = 16.0
      
    case .withBorderLine:
      self.placeHolderColor = .iDormColor(.iDormGray300)
      self.heightOfTextField = 51.0
      self.baseBackgroundColor = .white
      self.cornerRadius = 6.0
      self.leftPadding = 9.0
      self.borderWidth = 1
      self.borderColor = .iDormColor(.iDormGray300)
      
    default: break
    }
  }
  
  func setupLayouts() {
    [
      self.textField,
      self.openedEyeButton,
      self.closedEyeButton,
      self.checkCircleImageView
    ].forEach {
      self.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.textField.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      self.heightOfTextFieldConstraint = make.height.equalTo(54.0).constraint
    }
    
    self.openedEyeButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(8.0)
    }
    
    self.openedEyeButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(8.0)
    }
    
    self.checkCircleImageView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(8.0)
    }
  }
  
  // MARK: - Bind
  
  private func bind() {
    self.openedEyeButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.isSecureTextEntry = false
        owner.openedEyeButton.isHidden = true
        owner.closedEyeButton.isHidden = false
      }
      .disposed(by: self.disposeBag)
    
    self.closedEyeButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.isSecureTextEntry = true
        owner.openedEyeButton.isHidden = false
        owner.closedEyeButton.isHidden = true
      }
      .disposed(by: self.disposeBag)
    
    self.textField.rx.controlEvent(.editingDidBegin)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.borderColor = .iDormColor(.iDormBlue)
      }
      .disposed(by: self.disposeBag)
    
    self.textField.rx.controlEvent(.editingDidEnd)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        if let validationType = self.validationType {
          guard let text = self.text else { return }
          if ValidationManager.validate(text, validationType: validationType) {
            // 조건에 부합
            self.borderColor = .iDormColor(.iDormBlue)
            self.checkCircleImageView.isHidden = false
            self.openedEyeButton.isHidden = true
            self.closedEyeButton.isHidden = true
          } else {
            // 조건에 부합하지 않을 때
            self.borderColor = .iDormColor(.iDormRed)
            self.checkCircleImageView.isHidden = true
            self.openedEyeButton.isHidden = true
            self.closedEyeButton.isHidden = true
          }
        } else {
          owner.borderColor = .iDormColor(.iDormGray300)
        }
      }
      .disposed(by: self.disposeBag)
  }
}

extension NewiDormTextField {
  /// 텍스트 필드의 변경된 텍스트 값을 `Observable<String>`으로 방출합니다.
  var textObservable: Observable<String> {
    self.textField.rx.text.orEmpty.asObservable()
  }
  
  var editingDidEnd: Observable<Void> {
    self.textField.rx.controlEvent(.editingDidEnd).asObservable()
  }
  
  var editingDidBegin: Observable<Void> {
    self.textField.rx.controlEvent(.editingDidBegin).asObservable()
  }
}
