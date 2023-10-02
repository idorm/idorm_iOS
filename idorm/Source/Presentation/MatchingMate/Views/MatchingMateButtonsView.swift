//
//  MatchingMateButtonsView.swift
//  idorm
//
//  Created by 김응철 on 9/23/23.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

enum MatchingMateButtonType: CaseIterable {
  case dislike
  case reverse
  case message
  case like
  
  var image: UIImage? {
    switch self {
    case .dislike:
      return .iDormIcon(.matchingMate_dislike)
    case .reverse:
      return .iDormIcon(.matchingMate_reverse)
    case .message:
      return .iDormIcon(.matchingMate_message)
    case .like:
      return .iDormIcon(.matchingMate_like)
    }
  }
  
  var highlightedImage: UIImage? {
    switch self {
    case .dislike:
      return .iDormIcon(.matchingMate_dislike_highlighted)
    case .reverse:
      return .iDormIcon(.matchingMate_reverse_highlighted)
    case .message:
      return .iDormIcon(.matchingMate_message_highlighted)
    case .like:
      return .iDormIcon(.matchingMate_like_highlighted)
    }
  }
}

final class MatchingMateButtonsView: BaseView {
  
  // MARK: - UI Components
  
  /// 좋아요 `UIButton`
  private lazy var likeButton = self.button(.like)
  
  /// 싫어요 `UIButton`
  private lazy var dislikeButton = self.button(.dislike)
  
  /// 개인 메세지 보내기 `UIButton`
  private lazy var messageButton = self.button(.message)
  
  /// 카드 뒤로가기 `UIButton`
  private lazy var reverseButton = self.button(.reverse)
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView()
    [
      self.dislikeButton,
      self.reverseButton,
      self.messageButton,
      self.likeButton
    ].forEach {
      stackView.addArrangedSubview($0)
    }
    stackView.axis = .horizontal
    stackView.spacing = 18.0
    return stackView
  }()
  
  // MARK: - Properties
  
  var buttonHandler: ((MatchingMateButtonType) -> Void)?
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.backgroundColor = .clear
  }

  override func setupLayouts() {
    self.addSubview(self.stackView)
  }
  
  override func setupConstraints() {
    self.stackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    self.likeButton.rx.tap.asDriver()
      .drive(with: self) { owner, _ in
        owner.buttonHandler?(.like)
      }
      .disposed(by: self.disposeBag)
    
    self.dislikeButton.rx.tap.asDriver()
      .drive(with: self) { owner, _ in
        owner.buttonHandler?(.dislike)
      }
      .disposed(by: self.disposeBag)

    self.messageButton.rx.tap.asDriver()
      .drive(with: self) { owner, _ in
        owner.buttonHandler?(.message)
      }
      .disposed(by: self.disposeBag)

    self.reverseButton.rx.tap.asDriver()
      .drive(with: self) { owner, _ in
        owner.buttonHandler?(.reverse)
      }
      .disposed(by: self.disposeBag)
  }
}

// MARK: - Privates

private extension MatchingMateButtonsView {
  func button(_ buttonType: MatchingMateButtonType) -> iDormButton {
    let button = iDormButton(image: buttonType.image)
    button.contentInset = .zero
    button.baseBackgroundColor = .clear
      
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      guard let button = button as? iDormButton else { return }
      switch button.state {
      case .highlighted:
        button.image = buttonType.highlightedImage
      default:
        button.image = buttonType.image
      }
    }
    button.configurationUpdateHandler = handler
    return button
  }
}
