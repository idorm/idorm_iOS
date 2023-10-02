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
import RxGesture
 
final class iDormTextField: BaseView {
  
  enum iDormTextFieldType {
    case withBorderLine
    case login
    case custom
  }
  
  // MARK: - UI Components
  
  /// 메인이 되는 `UITextField`
  let textField: UITextField = {
    let textField = UITextField()
    return textField
  }()
  
  /// ic_openedEye인 `UIImageView`
  private let openedEyeButton: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .iDormIcon(.openedEye)
    imageView.isHidden = true
    return imageView
  }()
  
  /// ic_closedEye인 `UIImageView`
  private let closedEyeButton: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .iDormIcon(.closedEye)
    imageView.isHidden = true
    return imageView
  }()
  
  /// ic_checkCircle인 `UIImageView`
  private let checkCircleImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .iDormIcon(.checkCircle)
    imageView.isHidden = true
    return imageView
  }()
  
  /// ic_x_circle_mono인 `UIImageView`
  private let xCircleImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .iDormIcon(.x_circle_mono)
    imageView.isHidden = true
    return imageView
  }()
  
  // MARK: - Properties
  
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
  
  /// `OnboardingVC`에서 사용될 텍스트 필드인지 판별하는 `Bool`
  ///
  /// 이 값이 바뀌면 적절한 스트림들이 자동으로 구독됩니다.
  var isOnboarding: Bool = false {
    willSet {
      guard newValue else { return }
      
      self.editingDidBegin
        .asDriver(onErrorRecover: { _ in return .empty() })
        .drive(with: self) { owner, _ in
          owner.checkCircleImageView.isHidden = true
          owner.xCircleImageView.isHidden = false
        }
        .disposed(by: self.disposeBag)
      
      self.editingDidEnd
        .asDriver(onErrorRecover: { _ in return .empty() })
        .drive(with: self) { owner, _ in
          owner.xCircleImageView.isHidden = true
          owner.checkCircleImageView.isHidden = owner.text?.isEmpty ?? false ? true : false
        }
        .disposed(by: self.disposeBag)
    }
  }
  
  /// `ic_checkCircle`의 숨김처리를 할 수 있는 프로퍼티 입니다.
  var isHiddenCheckCircleImageView: Bool = true {
    willSet {
      self.checkCircleImageView.isHidden = newValue
    }
  }
  
  // MARK: - Initializer
  
  init(type: iDormTextFieldType) {
    self.iDormTextFieldType = type
    super.init(frame: .zero)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.font = .iDormFont(.medium, size: 14.0)
    self.textColor = .iDormColor(.iDormGray300)
    self.placeHolderFont = .iDormFont(.medium, size: 14.0)
    self.textField.addRightPadding(43.5)
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
  
  override func setupLayouts() {
    [
      self.textField,
      self.openedEyeButton,
      self.closedEyeButton,
      self.checkCircleImageView,
      self.xCircleImageView
    ].forEach {
      self.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.textField.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      self.heightOfTextFieldConstraint = make.height.equalTo(54.0).constraint
    }
    
    self.openedEyeButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(8.0)
    }
    
    self.closedEyeButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(8.0)
    }
    
    self.checkCircleImageView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(14.5)
    }
    
    self.xCircleImageView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(14.5)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    self.openedEyeButton.rx.tapGesture { _, delegate in
      delegate.simultaneousRecognitionPolicy = .never
    }
    .when(.recognized)
    .asDriver(onErrorRecover: { _ in return .empty() })
    .drive(with: self) { owner, _ in
      owner.isSecureTextEntry = false
      owner.openedEyeButton.isHidden = true
      owner.closedEyeButton.isHidden = false
    }
    .disposed(by: self.disposeBag)
    
    self.closedEyeButton.rx.tapGesture { _, delegate in
      delegate.simultaneousRecognitionPolicy = .never
    }
    .when(.recognized)
    .asDriver(onErrorRecover: { _ in return .empty() })
    .drive(with: self) { owner, _ in
      owner.isSecureTextEntry = true
      owner.openedEyeButton.isHidden = false
      owner.closedEyeButton.isHidden = true
    }
    .disposed(by: self.disposeBag)
    
    self.xCircleImageView.rx.tapGesture() { _, delegate in
      delegate.simultaneousRecognitionPolicy = .never
    }
      .when(.recognized)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.textField.rx.text.onNext("")
      }
      .disposed(by: self.disposeBag)
    
    self.textField.rx.controlEvent(.editingDidBegin)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.borderColor = .iDormColor(.iDormBlue)
        owner.checkCircleImageView.isHidden = true
        guard let validationType = self.validationType else { return }
        if case .password = validationType {
          if self.isSecureTextEntry {
            self.openedEyeButton.isHidden = false
          } else {
            self.closedEyeButton.isHidden = false
          }
        }
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

extension Reactive where Base: iDormTextField {
  var text: ControlProperty<String> {
    return base.textField.rx.text.orEmpty
  }
}

extension iDormTextField {
  var editingDidEnd: Observable<Void> {
    self.textField.rx.controlEvent(.editingDidEnd).asObservable()
  }
  
  var editingDidBegin: Observable<Void> {
    self.textField.rx.controlEvent(.editingDidBegin).asObservable()
  }
}
