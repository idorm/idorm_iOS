//
//  CommunityPostMultiBoxCell.swift
//  idorm
//
//  Created by 김응철 on 8/10/23.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

protocol CommunityPostMultiBoxCellDelegate: AnyObject {
  func didTapSympathyButton(_ nextIsLiked: Bool)
}

/// 게시글의 좋아요, 댓글, 사진 갯수와 공감하기 버튼이 포함되어 있는 `UICollectionViewCell`
final class CommunityPostMultiBoxCell: UICollectionViewCell, BaseView {
  
  // MARK: - UI Components
  
  /// `공감하기` 버튼
  private let sympathyButton: iDormButton = {
    let button = iDormButton("공감하기", image: nil)
    button.contentInset = .init(top: 6.0, leading: 10.0, bottom: 6.0, trailing: 10.0)
    button.cornerRadius = 4.0
    button.font = .iDormFont(.regular, size: 12.0)
    button.configurationUpdateHandler = { button in
      guard let button = button as? iDormButton else { return }
      switch button.state {
      case .selected:
        button.baseBackgroundColor = .iDormColor(.iDormBlue)
        button.baseForegroundColor = .white
      case .normal:
        button.baseBackgroundColor = .iDormColor(.iDormGray100)
        button.baseForegroundColor = .black
      default:
        break
      }
    }
    return button
  }()
  
  /// 게시글의 공감 갯수를 나타내는 `UIButton`
  private lazy var thumbButton = self.makeCountingButton(.iDormIcon(.thumb))
  
  /// 게시글의 댓글 갯수를 나타내는 `UIButton`
  private lazy var speechBubbleButton = self.makeCountingButton(.iDormIcon(.speechBubble))
  
  /// 게시글의 사진 갯수를 나타내는 `UIButton`
  private lazy var photoButton = self.makeCountingButton(.iDormIcon(.photo))
  
  /// 갯수를 나타내주는 버튼의 `UIStackView`
  private lazy var countingButtonStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [
      self.thumbButton, self.speechBubbleButton, self.photoButton
    ])
    stackView.axis = .horizontal
    stackView.spacing = 8.0
    return stackView
  }()
  
  /// 상단 경계를 나타내주는 `UIView`
  private lazy var topDivider = self.makeDivider()
  
  /// 하단 경계를 나타내주는 `UIView`
  private lazy var bottomDivider = self.makeDivider()
  
  // MARK: - Properties
  
  weak var delegate: CommunityPostMultiBoxCellDelegate?
  private var disposeBag = DisposeBag()
  
  // MARK: - Initializer
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupStyles()
    self.setupLayouts()
    self.setupConstraints()
    self.bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  func setupStyles() {}
  
  func setupLayouts() {
    [
      self.topDivider,
      self.bottomDivider,
      self.countingButtonStackView,
      self.sympathyButton
    ].forEach {
      self.contentView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.topDivider.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(1.0)
    }
    
    self.countingButtonStackView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().inset(20.0)
    }
    
    self.sympathyButton.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(24.0)
    }
    
    self.bottomDivider.snp.makeConstraints { make in
      make.bottom.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(1.0)
    }
  }
  
  // MARK: - Bind
  
  private func bind() {
    self.sympathyButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        owner.delegate?.didTapSympathyButton(!owner.sympathyButton.isSelected)
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Configure
  
  func configure(with post: Post) {
    self.thumbButton.title = "\(post.likesCount)"
    self.photoButton.title = "\(post.imagesCount)"
    self.speechBubbleButton.title = "\(post.commentsCount)"
    self.sympathyButton.isSelected = post.isLiked
  }
}

// MARK: - Privates

private extension CommunityPostMultiBoxCell {
  func makeCountingButton(_ icon: UIImage?) -> iDormButton {
    let button = iDormButton("", image: icon)
    button.configuration?.imagePlacement = .leading
    button.isUserInteractionEnabled = false
    button.baseBackgroundColor = .white
    button.baseForegroundColor = .iDormColor(.iDormGray300)
    button.imagePadding = 0.0
    button.edgeInsets = .zero
    return button
  }
  
  func makeDivider() -> UIView {
    let view = UIView()
    view.backgroundColor = .iDormColor(.iDormGray200)
    return view
  }
}
