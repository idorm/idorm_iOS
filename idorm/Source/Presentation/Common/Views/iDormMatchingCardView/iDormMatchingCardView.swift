//
//  idormMatchingCardView.swift
//  idorm
//
//  Created by 김응철 on 9/18/23.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class iDormMatchingCardView: BaseView {
  
  // MARK: - UI Components
  
  /// 메인이 되는 콘테이너 `UIView`
  private let topContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .iDormColor(.iDormCard)
    view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    view.layer.cornerRadius = 16.0
    return view
  }()
  
  /// 아래 인적사항이 적혀있는 콘테이너 `UIView`
  private let bottomContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.borderColor = UIColor.iDormColor(.iDormGray200).cgColor
    view.layer.borderWidth = 1.0
    return view
  }()
  
  /// `3기숙사`같이 어떤 종류의 기숙사인지 알려주는 `UILabel`
  private lazy var dormitoryLabel: UILabel = {
    let label = UILabel()
    label.textColor = .white
    label.font = .iDormFont(.bold, size: 20.0)
    label.text = self.matchingInfo.dormCategory.description
    return label
  }()
  
  /// 입사기간이 적혀있는 `UIButton`
  private lazy var joinPeriodButton: iDormButton = {
    let button = iDormButton(
      self.matchingInfo.joinPeriod.description,
      image: .iDormIcon(.dormitory)
    )
    button.baseBackgroundColor = .clear
    button.baseForegroundColor = .white
    button.contentInset = .zero
    button.isUserInteractionEnabled = false
    button.font = .iDormFont(.bold, size: 12.0)
    return button
  }()
  
  /// 코골이, 이갈이, 흡연이 들어있는 `UIStackView`
  private lazy var habitStackView: UIStackView = {
    let stackView = UIStackView()
    [
      iDormMatchingCardLabel(.snoring(self.matchingInfo.isSnoring)),
      iDormMatchingCardLabel(.grinding(self.matchingInfo.isGrinding)),
      iDormMatchingCardLabel(.smoking(self.matchingInfo.isSmoking))
    ].forEach { stackView.addArrangedSubview($0) }
    stackView.axis = .horizontal
    stackView.spacing = 7.0
    return stackView
  }()
  
  /// 실내 음식, 이어폰 착용이 들어있는 `UIStackView`
  private lazy var habitStackView2: UIStackView = {
    let stackView = UIStackView()
    [
      iDormMatchingCardLabel(.allowedFood(self.matchingInfo.isAllowedFood)),
      iDormMatchingCardLabel(.allowedEarphones(self.matchingInfo.isWearEarphones))
    ].forEach { stackView.addArrangedSubview($0) }
    stackView.axis = .horizontal
    stackView.spacing = 7.0
    return stackView
  }()
  
  /// 기상시간, 정리정돈, 샤워시간, MBTI가 들어있는 `UIStackView`
  private lazy var verticalStackView: UIStackView = {
    let stackView = UIStackView()
    [
      iDormMatchingCardLabel(.wakeUpTime(self.matchingInfo.wakeUpTime)),
      iDormMatchingCardLabel(.arrangement(self.matchingInfo.cleanUpStatus)),
      iDormMatchingCardLabel(.showerTime(self.matchingInfo.showerTime)),
      iDormMatchingCardLabel(.mbti(self.matchingInfo.mbti))
    ].forEach { stackView.addArrangedSubview($0) }
    stackView.axis = .vertical
    stackView.spacing = 8.0
    return stackView
  }()
  
  /// 하고싶은 말이 적혀있는 `UIView`
  private lazy var wantToSayView = iDormMatchingCardTextView(self.matchingInfo.wishText)
  
  /// 성별과 나이가 적혀있는 `UIButton`
  private lazy var genderAndAgeButton: iDormButton = {
    let gender = self.matchingInfo.gender.description
    let age = self.matchingInfo.age
    let button = iDormButton("\(gender), \(age) 세", image: .iDormIcon(.human_fill))
    button.baseBackgroundColor = .clear
    button.baseForegroundColor = .iDormColor(.iDormGray400)
    button.contentInset = .zero
    button.isUserInteractionEnabled = false
    button.font = .iDormFont(.bold, size: 12.0)
    button.imagePadding = 8.0
    return button
  }()
  
  /// MBTI가 적혀있는 `UILabel`
  private lazy var mbtiLabel: UILabel = {
    let label = UILabel()
    label.text = self.matchingInfo.mbti
    label.textColor = .iDormColor(.iDormGray300)
    label.font = .iDormFont(.bold, size: 12.0)
    return label
  }()
  
  /// ic_option `UIButton`
  private let optionButton: UIButton = {
    let button = UIButton()
    button.setImage(.iDormIcon(.option)?.withTintColor(.iDormColor(.iDormGray300)), for: .normal)
    return button
  }()
  
  // MARK: - Properties
  
  private let matchingInfo: MatchingInfo
  var optionButtonHandler: ((MatchingInfo) -> Void)?
  
  // MARK: - Initializer
  
  init(_ matchingInfo: MatchingInfo) {
    self.matchingInfo = matchingInfo
    super.init(frame: .zero)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  override func setupLayouts() {
    self.addSubview(self.topContainerView)
    self.addSubview(self.bottomContainerView)
    [
      self.dormitoryLabel,
      self.joinPeriodButton,
      self.habitStackView,
      self.habitStackView2,
      self.verticalStackView,
      self.wantToSayView
    ].forEach {
      self.topContainerView.addSubview($0)
    }
    [
      self.genderAndAgeButton,
      self.mbtiLabel,
      self.optionButton
    ].forEach {
      self.bottomContainerView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.topContainerView.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(396.0)
      make.width.equalTo(327.0)
    }
    
    self.bottomContainerView.snp.makeConstraints { make in
      make.top.equalTo(self.topContainerView.snp.bottom).offset(-1.0)
      make.bottom.directionalHorizontalEdges.equalToSuperview()
      make.height.equalTo(36.0)
      make.width.equalTo(327.0)
    }
    
    self.dormitoryLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(13.0)
      make.leading.equalToSuperview().inset(21.0)
    }

    self.joinPeriodButton.snp.makeConstraints { make in
      make.centerY.equalTo(self.dormitoryLabel)
      make.trailing.equalToSuperview().inset(20.0)
    }
    
    self.habitStackView.snp.makeConstraints { make in
      make.top.equalTo(self.dormitoryLabel.snp.bottom).offset(10.0)
      make.leading.equalToSuperview().inset(13.0)
    }
    
    self.habitStackView2.snp.makeConstraints { make in
      make.top.equalTo(self.habitStackView.snp.bottom).offset(8.0)
      make.leading.equalToSuperview().inset(13.0)
    }
    
    self.verticalStackView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(13.0)
      make.top.equalTo(self.habitStackView2.snp.bottom).offset(10.0)
    }
    
    self.wantToSayView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(13.0)
      make.top.equalTo(self.verticalStackView.snp.bottom).offset(10.0)
      make.height.equalTo(104.0)
    }
    
    self.genderAndAgeButton.snp.makeConstraints { make in
      make.centerY.equalTo(self.bottomContainerView)
      make.leading.equalToSuperview().inset(10.0)
    }
    
    self.optionButton.snp.makeConstraints { make in
      make.centerY.equalTo(self.bottomContainerView)
      make.trailing.equalToSuperview().inset(5.0)
    }
    
    self.mbtiLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.bottomContainerView)
      make.trailing.equalTo(self.optionButton.snp.leading)
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    self.optionButton.rx.tap.asDriver()
      .drive(with: self) { owner, _ in
        owner.optionButtonHandler?(owner.matchingInfo)
      }
      .disposed(by: self.disposeBag)
  }
}
