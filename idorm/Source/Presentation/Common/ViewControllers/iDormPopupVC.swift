//
//  BasePopupViewController.swift
//  idorm
//
//  Created by 김응철 on 9/27/23.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa
import RxGesture

final class iDormPopupViewController: BaseViewController {
  
  enum ViewType {
    case alert(AlertButtonType)
    case kakao
    case noMatchingInfo
    case noPublicMatchingInfo
    case welcome
  }
  
  enum AlertButtonType {
    case oneButton(contents: String)
    case twoButton(contents: String, buttonTitle: String)
  }
  
  // MARK: - UI Components
  
  /// 정중앙에 위치해있는 하얀색 `UIView`
  private let containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.clipsToBounds = true
    view.layer.cornerRadius = 12
    return view
  }()
  
  private lazy var cancelButton: UIButton = {
    let button = UIButton()
    button.setImage(.iDormIcon(.cancel), for: .normal)
    switch self.viewType {
    case .alert:
      button.isHidden = true
    default:
      button.isHidden = false
    }
    return button
  }()
  
  private lazy var confirmButton: iDormButton = {
    let button = iDormButton()
    button.imagePadding = 10.0
    button.cornerRadius = 10.0
    button.baseBackgroundColor = .iDormColor(.iDormBlue)
    button.baseForegroundColor = .white
    button.font = .iDormFont(.medium, size: 14.0)
    switch self.viewType {
    case .alert, .noPublicMatchingInfo:
      button.isHidden = true
    case .kakao:
      button.title = "카카오톡으로 이동"
      button.image = .iDormIcon(.kakao)
    case .noMatchingInfo, .welcome:
      button.title = "프로필 이미지 만들기"
    }
    return button
  }()
  
  private lazy var contentLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.medium, size: 14.0)
    label.textColor = .black
    label.numberOfLines = 0
    label.textAlignment = .center
    switch self.viewType {
    case .alert(let alertButtonType):
      label.textAlignment = .left
      switch alertButtonType {
      case .oneButton(let content):
        label.text = content
      case .twoButton(let content, _):
        label.text = content
      }
    case .kakao:
      label.text = "상대의 카카오톡 오픈채팅으로 이동합니다."
    case .noMatchingInfo, .welcome:
      label.text = "룸메이트 매칭을 위해\n우선 매칭 이미지를 만들어 주세요."
    case .noPublicMatchingInfo:
      label.text = "룸메이트 매칭을 위해\n우선 내 매칭 이미지를\n매칭페이지에 공개해야 해요."
    }
    return label
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = .iDormFont(.medium, size: 16.0)
    switch self.viewType {
    case .alert, .kakao, .noPublicMatchingInfo:
      label.isHidden = true
    case .noMatchingInfo:
      label.text = "매칭 이미지가 아직 없어요. 😅"
    case .welcome:
      label.text = "i dorm에 처음 오셨네요! 🙂"
    }
    return label
  }()
  
  private lazy var confirmTextButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitle("확인", for: .normal)
    button.setTitleColor(.iDormColor(.iDormBlue), for: .normal)
    button.titleLabel?.font = .iDormFont(.medium, size: 14.0)
    switch self.viewType {
    case .alert(let alertButtonType):
      switch alertButtonType {
      case .oneButton:
        break
      case .twoButton(_, let buttonTitle):
        button.setTitle(buttonTitle, for: .normal)
      }
    case .noPublicMatchingInfo:
      button.setTitle("공개 허용", for: .normal)
    default:
      break
    }
    return button
  }()
  
  private lazy var cancelTextButton: UIButton = {
    let button = UIButton()
    button.setTitle("취소", for: .normal)
    button.setTitleColor(.iDormColor(.iDormGray300), for: .normal)
    button.titleLabel?.font = .iDormFont(.medium, size: 14.0)
    switch self.viewType {
    case .alert(let alertButtonType):
      switch alertButtonType {
      case .oneButton:
        button.isHidden = true
      case .twoButton:
        break
      }
    default: break
    }
    return button
  }()
  
  private lazy var buttonStack: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [
      self.cancelTextButton, self.confirmTextButton
    ])
    stackView.axis = .horizontal
    stackView.spacing = 24.0
    switch self.viewType {
    case .alert, .noPublicMatchingInfo:
      break
    default:
      stackView.isHidden = true
    }
    return stackView
  }()

  // MARK: - Properties
  
  var confirmButtonHandler: (() -> Void)?
  private let viewType: ViewType
  
  // MARK: - Initializer
  
  init(_ viewType: ViewType) {
    self.viewType = viewType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.view.backgroundColor = .black.withAlphaComponent(0.5)
  }
  
  override func setupLayouts() {
    self.view.addSubview(self.containerView)
    [
      self.cancelButton,
      self.confirmButton,
      self.contentLabel,
      self.buttonStack,
      self.titleLabel
    ].forEach {
      self.containerView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    switch self.viewType {
    case .alert:
      self.containerView.snp.makeConstraints { make in
        make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
        make.bottom.equalTo(self.buttonStack.snp.bottom).offset(16.0)
        make.centerY.equalToSuperview()
      }
      
      self.contentLabel.snp.makeConstraints { make in
        make.directionalHorizontalEdges.equalToSuperview().inset(16.0)
        make.top.equalToSuperview().inset(26.0)
      }
    default:
      self.containerView.snp.makeConstraints { make in
        make.centerY.equalToSuperview()
        make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
        make.height.equalTo(230.0)
      }
      
      self.contentLabel.snp.makeConstraints { make in
        make.top.equalTo(self.cancelButton.snp.bottom).offset(36.0)
        make.centerX.equalToSuperview()
      }
    }
    
    self.buttonStack.snp.makeConstraints { make in
      if case .noPublicMatchingInfo = self.viewType {
        make.top.equalTo(self.contentLabel.snp.bottom).offset(36.0)
      } else {
        make.top.equalTo(self.contentLabel.snp.bottom).offset(46.0)
      }
      make.trailing.equalToSuperview().inset(14.0)
    }

    self.cancelButton.snp.makeConstraints { make in
      make.top.trailing.equalToSuperview().inset(16.0)
    }
    
    self.containerView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
    }
    
    self.confirmButton.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
      make.bottom.equalToSuperview().inset(20.0)
      make.height.equalTo(53.0)
    }
    
    self.titleLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.cancelButton)
      make.leading.equalToSuperview().inset(16.0)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    self.view.rx.tapGesture()
      .when(.recognized)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.dismiss(animated: false)
      }
      .disposed(by: self.disposeBag)
    
    self.cancelButton.rx.tap.asDriver()
      .drive(with: self) { owner, _ in
        owner.dismiss(animated: false)
      }
      .disposed(by: self.disposeBag)
    
    self.confirmButton.rx.tap.asDriver()
      .drive(with: self) { owner, _ in
        owner.dismiss(animated: false)
        owner.confirmButtonHandler?()
      }
      .disposed(by: self.disposeBag)
    
    confirmTextButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.dismiss(animated: false)
        owner.confirmButtonHandler?()
      }
      .disposed(by: disposeBag)
    
    self.cancelTextButton.rx.tap
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.dismiss(animated: false)
      }
      .disposed(by: disposeBag)
  }
}
