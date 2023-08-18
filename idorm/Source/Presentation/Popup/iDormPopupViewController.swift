//
//  PopupViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/10.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa
import RxGesture

@objc protocol iDormPopupViewControllerDelegate: AnyObject {
  @objc optional func confirmButtonDidTap()
}

/// 안내 문구 또는 확인 절차를 밟기 위한 `Popup`형태의 `ViewController`
final class iDormPopupViewController: BaseViewController {
  
  enum iDormPopupViewType {
    case oneButton(contents: String)
    case twoButton(contents: String, buttonTitle: String)
  }
  
  // MARK: - UI Components
  
  /// 정중앙에 위치해있는 하얀색 `UIView`
  lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.clipsToBounds = true
    view.layer.cornerRadius = 12
    return view
  }()
  
  /// 안내 문구가 적혀있는 `UILabel`
  lazy var contentsLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = .init(name: IdormFont_deprecated.medium.rawValue, size: 14.0)
    label.numberOfLines = 0
    return label
  }()
  
  /// `확인` 버튼
  let confirmButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitle("확인", for: .normal)
    button.setTitleColor(.iDormColor(.iDormBlue), for: .normal)
    button.titleLabel?.font = .iDormFont(.medium, size: 14.0)
    return button
  }()
  
  /// `취소` 버튼
  private let cancelButton: UIButton = {
    let button = UIButton()
    button.setTitle("취소", for: .normal)
    button.setTitleColor(.iDormColor(.iDormGray300), for: .normal)
    button.titleLabel?.font = .iDormFont(.medium, size: 14.0)
    return button
  }()
  
  /// 두 개의 버튼이 들어있는 `UIStackView`
  private lazy var buttonStack: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [self.cancelButton, self.confirmButton])
    stackView.axis = .horizontal
    stackView.spacing = 24.0
    return stackView
  }()
  
  // MARK: - Properties
  
  weak var delegate: iDormPopupViewControllerDelegate?
  private var viewType: iDormPopupViewType
  
  /// 확인 버튼이 눌렸을 때 실행되는 클로저입니다.
  var confirmButtonCompletion: (() -> Void)?
  
  // MARK: - LifeCycle
  
  init(contents: String) {
    self.viewType = .oneButton(contents: contents)
    super.init(nibName: nil, bundle: nil)
  }
  
  init(viewType: iDormPopupViewType) {
    self.viewType = viewType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    self.view.backgroundColor = .black.withAlphaComponent(0.5)
    self.configureUI()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.view.addSubview(containerView)
    [
      self.contentsLabel,
      self.buttonStack
    ].forEach {
      self.containerView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.containerView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(32.0)
      make.bottom.equalTo(self.buttonStack.snp.bottom).offset(16.0)
      make.centerY.equalToSuperview()
    }
    
    self.contentsLabel.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(16.0)
      make.top.equalToSuperview().inset(26.0)
    }
    
    self.buttonStack.snp.makeConstraints { make in
      make.top.equalTo(self.contentsLabel.snp.bottom).offset(46.0)
      make.trailing.equalToSuperview().inset(14.0)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // 확인 버튼 클릭 이벤트
    confirmButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.dismiss(animated: false)
        owner.delegate?.confirmButtonDidTap?()
        owner.confirmButtonCompletion?()
      }
      .disposed(by: disposeBag)
    
    // 취소 버튼 클릭 이벤트
    self.cancelButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.dismiss(animated: false)
      }
      .disposed(by: disposeBag)
    
    // 화면 빈 공간 터치
    self.view.rx.tapGesture()
      .when(.recognized)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.dismiss(animated: false)
      }
      .disposed(by: self.disposeBag)
  }
}

// MARK: - Privates

private extension iDormPopupViewController {
  func configureUI() {
    switch self.viewType {
    case .oneButton(let contents):
      self.cancelButton.isHidden = true
      self.contentsLabel.text = contents
    case let .twoButton(contents, buttonTitle):
      self.cancelButton.isHidden = false
      self.contentsLabel.text = contents
      self.confirmButton.setTitle(buttonTitle, for: .normal)
    }
  }
}
