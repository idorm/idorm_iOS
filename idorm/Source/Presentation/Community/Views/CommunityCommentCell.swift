//
//  CommunityDetailTableViewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/21.
//

import UIKit

import SnapKit
import Kingfisher
import RxSwift
import RxCocoa

protocol CommunityCommentCellDelegate: AnyObject {
  func didTapReplyButton(_ commentID: Int, cell: CommunityCommentCell)
  func didTapOptionButton(_ comment: Comment)
}

final class CommunityCommentCell: UICollectionViewCell, BaseViewProtocol {
  
  // MARK: - UI Components
  
  /// 유저의 사진을 보여주는 `UIImageView`
  private let profileImageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFill
    iv.backgroundColor = .iDormColor(.iDormGray300)
    iv.layer.cornerRadius = 8
    iv.layer.masksToBounds = true
    return iv
  }()
  
  /// 유저의 닉네임 `UILabel`
  private let nicknameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = .iDormFont(.medium, size: 14.0)
    return label
  }()
  
  /// 유저의 댓글 단 시간 `UILabel`
  private let timeLabel: UILabel = {
    let label = UILabel()
    label.font = .iDormFont(.regular, size: 12.0)
    label.textColor = .iDormColor(.iDormGray300)
    return label
  }()
  
  /// `nicknameLabel`, `timeLabel`을 가지고 있는 `UIStackView`
  private lazy var profileStackView: UIStackView = {
    let sv = UIStackView(arrangedSubviews: [self.nicknameLabel, self.timeLabel])
    sv.axis = .vertical
    sv.alignment = .leading
    return sv
  }()
  
  /// 옵션 `UIButton`
  private let optionButton: iDormButton = {
    let image = UIImage.iDormIcon(.option)
    let button = iDormButton("", image: image)
    button.baseBackgroundColor = .white
    return button
  }()
  
  /// 유저의 댓글 내용 `UILabel`
  private let contentLabel: UILabel = {
    let label = UILabel()
    label.textColor = .iDormColor(.iDormGray400)
    label.font = .iDormFont(.medium, size: 14.0)
    label.numberOfLines = 0
    return label
  }()
  
  /// 답글 쓰기 `UIButton`
  private let replyButton: iDormButton = {
    let button = iDormButton("답글 쓰기", image: nil)
    button.contentInset = .init(top: 6.0, leading: 10.0, bottom: 6.0, trailing: 10.0)
    button.baseBackgroundColor = .iDormColor(.iDormGray100)
    button.baseForegroundColor = .black
    button.font = .iDormFont(.regular, size: 12.0)
    button.isHidden = true
    return button
  }()
  
  /// 하단의 경계를 나타내주는 `UIView`
  private let bottomDivider: UIView = {
    let view = UIView()
    view.backgroundColor = .iDormColor(.iDormGray200)
    return view
  }()
  
  /// 첫 번째 답글에서 나타나는 `UIImageView`
  private let replyImageView: UIImageView = {
    let imageView = UIImageView()
    let image: UIImage? = .iDormIcon(.reply)?
      .withTintColor(.iDormColor(.iDormGray200))
    imageView.image = image
    imageView.isHidden = true
    return imageView
  }()
  
  // MARK: - Properties
  
  weak var delegate: CommunityCommentCellDelegate?
  private var disposeBag = DisposeBag()
  private var topConstraints: Constraint?
  private var bottomConstarints: Constraint?
  
  /// `confiure(with:)`를 통해서 저장되어 있는 `Comment`
  var comment: Comment?
  
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
      self.replyImageView,
      self.profileImageView,
      self.profileStackView,
      self.optionButton,
      self.contentLabel,
      self.replyButton,
      self.bottomDivider
    ].forEach {
      self.contentView.addSubview($0)
    }
  }
  
  func setupConstraints() {
    self.replyImageView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(16.0)
      make.leading.equalToSuperview().inset(24.0)
    }
    
    self.profileImageView.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24.0)
      self.topConstraints = make.top.equalToSuperview().inset(56.0).constraint
      make.width.height.equalTo(42.0)
    }
    
    self.profileStackView.snp.makeConstraints { make in
      make.centerY.equalTo(profileImageView)
      make.leading.equalTo(profileImageView.snp.trailing).offset(10.0)
      make.trailing.equalTo(optionButton.snp.leading).offset(-10.0)
    }
    
    self.contentLabel.snp.makeConstraints { make in
      make.leading.equalTo(profileStackView.snp.leading)
      make.top.equalTo(profileStackView.snp.bottom).offset(8.0)
      make.trailing.equalToSuperview().inset(24.0)
      self.bottomConstarints = make.bottom.equalToSuperview().inset(56.0).constraint
    }
    
    self.replyButton.snp.makeConstraints { make in
      make.top.equalTo(contentLabel.snp.bottom).offset(10.0)
      make.leading.equalTo(profileStackView.snp.leading)
    }
    
    self.optionButton.snp.makeConstraints { make in
      make.top.equalTo(self.profileImageView.snp.top)
      make.trailing.equalToSuperview().inset(14.0)
    }
    
    self.bottomDivider.snp.makeConstraints { make in
      make.bottom.leading.trailing.equalToSuperview()
      make.height.equalTo(1.0)
    }
  }
  
  // MARK: - Bind
  
  private func bind() {
    self.replyButton.rx.tap
      .compactMap { self.comment?.commentId }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, commentID in
        owner.delegate?.didTapReplyButton(commentID, cell: owner)
      }
      .disposed(by: self.disposeBag)
    
    self.optionButton.rx.tap
      .compactMap { self.comment }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, comment in
        owner.delegate?.didTapOptionButton(comment)
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Configure
  
  /// 외부에서 주입된 `Comment`타입을 통해
  /// `Cell`에 UI를 변경합니다.
  ///
  /// - Parameters:
  ///    - comment: 데이터를 주입할 댓글
  func configure(with comment: Comment) {
    // Data Binding
    self.comment = comment
    self.profileImageView.image = .iDormImage(.human)
    if let profileUrl = comment.profileUrl,
       !comment.isAnonymous
    { self.profileImageView.kf.setImage(with: URL(string: profileUrl)!) }
    self.comment = comment
    self.nicknameLabel.text = comment.nickname ?? "탈퇴한 사용자"
    self.timeLabel.text = comment.createdAt.toCommunityPostFormatString()
    self.contentLabel.text = comment.content
    
    // UI
    self.replyButton.isHidden = true
    self.replyImageView.isHidden = true
    self.nicknameLabel.textColor = .black
    self.contentView.backgroundColor = .white
    self.bottomDivider.isHidden = comment.isLast ? false : true
    self.topConstraints?.update(inset: 16.0)
    self.bottomConstarints?.update(inset: 16.0)
    
    switch comment.state {
    case .firstReply:
      self.replyImageView.isHidden = false
      self.contentView.backgroundColor = .iDormColor(.iDormMatchingScreen)
      self.topConstraints?.update(inset: 56.0)
    case .reply:
      self.contentView.backgroundColor = .iDormColor(.iDormMatchingScreen)
    case .normal(let isRemoved):
      if isRemoved {
        self.nicknameLabel.text = "삭제"
        self.nicknameLabel.textColor = .iDormColor(.iDormGray300)
        self.contentLabel.text = "삭제된 댓글입니다."
      } else {
        self.replyButton.isHidden = false
        self.bottomConstarints?.update(inset: 56.0)
      }
    }
  }
}
