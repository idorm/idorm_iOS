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

final class CalendarMemberView: UIView, BaseView {
  
  // MARK: - UI Components
  
  /// 멤버의 프로필 이미지가 들어가는 `UIImageView`
  private let profileImageView: UIImageView = {
    let iv = UIImageView()
    iv.layer.cornerRadius = 24.0
    iv.layer.borderWidth = 3.0
    iv.contentMode = .scaleAspectFit
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
    return view
  }()
  
  // MARK: - Properties
  
  private var disposeBag = DisposeBag()
  private var teamMember: TeamCalendarSingleMemberResponseDTO?
  
  /// 현재 선택 버튼이 선택 되었는지 판별해주는 `BehaviorRealy<Bool>`
  let isSelected = BehaviorRelay<Bool>(value: false)
  
  /// 현재 팀 멤버에 대한 `memberId`
  var memberId: Int { self.teamMember?.memberId ?? 0 }
  
  /// 선택 버튼의 숨김 처리의 유무를 판별해주는 `Bool`
  var isHiddenSelectionButton: Bool = true {
    willSet { self.memberSelectionButton.isHidden = newValue }
  }
  
  // MARK: - Initializer
  
  /// 이 `View`를 생성하기 위해서는
  /// `TeamMember` 모델이 필요합니다.
  ///
  /// - Parameters:
  ///  - teamMember: `TeamMember` Model
  convenience init(_ teamMember: TeamCalendarSingleMemberResponseDTO, isEditing: Bool) {
    self.init(frame: .zero)
    self.teamMember = teamMember
    self.configure(with: teamMember, isEditing: isEditing)
  }
  
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
  
  func setupConstraints() {
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
  
  private func bind() {
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
    
    /// 버튼의 `isSelected`상태를 변경합니다.
    self.isSelected
      .distinctUntilChanged()
      .bind(to: self.memberSelectionButton.rx.isSelected)
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Configure
  
  /// 데이터를 가지고 UI를 업데이트합니다.
  ///
  /// - Parameters:
  ///  - teamMember: 업데이트할 `TeamMember` 모델
  func configure(with teamMember: TeamCalendarSingleMemberResponseDTO, isEditing: Bool) {
    // 멤버 사진
    self.profileImageView.image = .iDormImage(.human)
    if let urlString = teamMember.profilePhotoUrl {
      self.profileImageView.kf.setImage(with: URL(string: urlString)!)
    }
    // 멤버 닉네임
    self.nicknameLabel.text = teamMember.nickname
    
    // 멤버 이미지 테두리 색상
    let borderColor: UIColor
    switch teamMember.order {
    case 0: borderColor = .iDormColor(.firstUser)
    case 1: borderColor = .iDormColor(.secondUser)
    case 2: borderColor = .iDormColor(.thirdUser)
    case 3: borderColor = .iDormColor(.fourthUser)
    default: borderColor = .iDormColor(.firstUser)
    }
    self.profileImageView.layer.borderColor = borderColor.cgColor
    
    self.alphaView.isHidden = true
    self.trashcanImageView.isHidden = true
    self.sleepoverLabel.isHidden = true
    
    if isEditing {
      // 수정중
      self.alphaView.isHidden = false
      self.trashcanImageView.isHidden = false
    } else {
      if teamMember.sleepoverYn {
        // 외박 중
        self.alphaView.isHidden = false
        self.sleepoverLabel.isHidden = false
      }
    }
  }
}
