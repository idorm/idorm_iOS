//
//  CalendarMemberView.swift
//  idorm
//
//  Created by 김응철 on 7/26/23.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa
import RxGesture

final class CalendarMemberView: BaseView {
  
  // MARK: - UI Components
  
  /// 멤버의 프로필 이미지가 들어가는 `UIImageView`
  private let profileImageView: UIImageView = {
    let iv = UIImageView()
    iv.layer.cornerRadius = 24.0
    iv.layer.borderWidth = 3.0
    iv.contentMode = .scaleAspectFill
    iv.layer.masksToBounds = true
    iv.backgroundColor = .iDormColor(.iDormBlue)
    return iv
  }()
  
  /// 멤버의 닉네임이 들어가는 `UILabel`
  private let nicknameLabel: UILabel = {
    let lb = UILabel()
    lb.font = .iDormFont(.regular, size: 10)
    lb.textColor = .iDormColor(.iDormGray400)
    lb.numberOfLines = 2
    lb.textAlignment = .center
    return lb
  }()
  
  /// 멤버를 선택의 유무를 알 수 있는 `UIButton`
  private let memberSelectionButton: UIButton = {
    let button = UIButton()
    button.setImage(.iDormIcon(.deselect), for: .normal)
    button.setImage(.iDormIcon(.select), for: .selected)
    button.isHidden = true
    button.isUserInteractionEnabled = false
    return button
  }()
  
  /// `ic_trashcan` 아이콘이 들어있는 `UIImageView`
  private let trashcanImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .iDormIcon(.trashcan)?
      .resize(newSize: 18.0)?
      .withTintColor(.white)
    imageView.isHidden = true
    return imageView
  }()
  
  /// `외박`이 적혀있는 `UILabel`
  private let sleepoverLabel: UILabel = {
    let label = UILabel()
    label.text = "외박😴"
    label.font = .iDormFont(.medium, size: 10.0)
    label.textColor = .white
    label.isHidden = true
    return label
  }()
  
  /// 수정할 때의 이미지의 알파값을 주기위한 `UIView`
  private let alphaView: UIView = {
    let view = UIView()
    view.backgroundColor = .black.withAlphaComponent(0.5)
    view.layer.cornerRadius = 22.5
    view.isHidden = true
    return view
  }()
  
  // MARK: - Properties
  
  var teamMember: TeamMember = .init() {
    willSet {
      self.profileImageView.image = .iDormImage(.human)
      if let urlString = newValue.profilePhotoURL {
        self.profileImageView.kf.setImage(with: URL(string: urlString)!)
      }
      self.nicknameLabel.text = teamMember.nickname
      let borderColor: UIColor
      switch teamMember.order {
      case 0: borderColor = .iDormColor(.firstUser)
      case 1: borderColor = .iDormColor(.secondUser)
      case 2: borderColor = .iDormColor(.thirdUser)
      case 3: borderColor = .iDormColor(.fourthUser)
      default: borderColor = .iDormColor(.firstUser)
      }
      self.profileImageView.layer.borderColor = borderColor.cgColor
      if newValue.isSleepover {
        self.alphaView.isHidden = false
        self.sleepoverLabel.isHidden = false
      }
    }
  }
  
  var isEditing: Bool = false {
    willSet {
      self.trashcanImageView.isHidden = !newValue
      self.sleepoverLabel.isHidden = newValue
      guard !self.teamMember.isSleepover else { return }
      self.alphaView.isHidden = !newValue
    }
  }
  
  var isHiddenSelectionButton: Bool = true {
    willSet { self.memberSelectionButton.isHidden = newValue }
  }
  
  var isSelected = BehaviorRelay<Bool>(value: false)
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.profileImageView,
      self.nicknameLabel,
      self.memberSelectionButton,
      self.alphaView,
      self.trashcanImageView,
      self.sleepoverLabel
    ].forEach {
      self.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.snp.makeConstraints { make in
      make.width.equalTo(48.0)
      make.height.equalTo(80.0)
    }
    
    self.profileImageView.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
      make.width.height.equalTo(48.0)
    }
    
    self.nicknameLabel.snp.makeConstraints { make in
      make.top.equalTo(self.profileImageView.snp.bottom).offset(8)
      make.directionalHorizontalEdges.equalToSuperview()
    }
    
    self.memberSelectionButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(32.5)
      make.top.equalToSuperview().inset(32.5)
    }
    
    self.trashcanImageView.snp.makeConstraints { make in
      make.center.equalTo(self.profileImageView)
    }
    
    self.alphaView.snp.makeConstraints { make in
      make.size.equalTo(45.0)
      make.center.equalTo(self.profileImageView)
    }
    
    self.sleepoverLabel.snp.makeConstraints { make in
      make.center.equalTo(self.alphaView)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    /// `View` 터치
    self.rx.tapGesture { gesture, _ in
      gesture.cancelsTouchesInView = false
    }
      .when(.recognized)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with : self) { owner, _ in
        owner.isSelected.accept(!owner.memberSelectionButton.isSelected)
      }
      .disposed(by: self.disposeBag)
    
    self.isSelected
      .distinctUntilChanged()
      .bind(to: self.memberSelectionButton.rx.isSelected)
      .disposed(by: self.disposeBag)
  }
}
