//
//  OnboardingViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/25.
//

import UIKit

import SnapKit
import Then
import AEOTPTextField
import RSKGrowingTextView
import RxSwift
import RxCocoa
import RxGesture
import RxAppState
import ReactorKit
import RxOptional

final class OnboardingViewController: BaseViewController, View {
  
  // MARK: - Properties
  
  private let indicator = UIActivityIndicatorView().then {
    $0.color = .darkGray
  }
  
  private let scrollView = UIScrollView()
  
  private lazy var dormStack = UIStackView().then { stack in
    [dorm1Button, dorm2Button, dorm3Button]
      .forEach { stack.addArrangedSubview($0) }
    stack.spacing = 12
  }
  
  private lazy var genderStack = UIStackView().then { stack in
    [maleButton, femaleButton]
      .forEach { stack.addArrangedSubview($0) }
    stack.spacing = 12
  }
  
  private lazy var periodStack = UIStackView().then { stack in
    [period16Button, period24Button]
      .forEach { stack.addArrangedSubview($0) }
    stack.spacing = 12
  }
  
  private lazy var habitStack1 = UIStackView().then { stack in
    [snoreButton, grindingButton, smokingButton]
      .forEach { stack.addArrangedSubview($0) }
    stack.spacing = 12
  }
  
  private lazy var habitStack2 = UIStackView().then { stack in
    [allowedFoodButton, allowedEarphoneButton]
      .forEach { stack.addArrangedSubview($0) }
    stack.spacing = 12
  }
  
  private lazy var ageTextField = AEOTPTextField().then {
    $0.otpDefaultBorderColor = .idorm_gray_200
    $0.otpFilledBorderColor = .idorm_gray_200
    $0.otpFilledBorderWidth = 1
    $0.otpDefaultBorderWidth = 1
    $0.otpFont = .idormFont(.medium, size: 14)
    $0.otpTextColor = .idorm_gray_400
    $0.otpBackgroundColor = .white
    $0.otpFilledBackgroundColor = .white
    $0.configure(with: 2)
    $0.clearOTP()
  }
  
  private let chatDescriptionLabel = UIFactory.label(
    "open.kakao 카카오 오픈채팅 형식을 기입해주세요.",
    textColor: .idorm_gray_300,
    font: .idormFont(.medium, size: 14)
  )
  
  private let wishTextView = RSKGrowingTextView().then {
    $0.attributedPlaceholder = NSAttributedString(
      string: "입력",
      attributes: [
        NSAttributedString.Key.font: UIFont.idormFont(.regular, size: 14),
        NSAttributedString.Key.foregroundColor: UIColor.idorm_gray_300]
    )
    $0.font = .idormFont(.regular, size: 14)
    $0.textColor = .black
    $0.layer.cornerRadius = 10
    $0.layer.borderColor = UIColor.idorm_gray_300.cgColor
    $0.layer.borderWidth = 1
    $0.isScrollEnabled = false
    $0.keyboardType = .default
    $0.returnKeyType = .done
    $0.backgroundColor = .clear
    $0.textContainerInset = UIEdgeInsets(top: 15, left: 9, bottom: 15, right: 9)
  }
  
  private let maxLengthLabel = UIFactory.label(
    "/ 100 pt",
    textColor: .idorm_gray_300,
    font: .idormFont(.medium, size: 14)
  )
  
  private let currentLengthLabel = UIFactory.label(
    "0",
    textColor: .idorm_blue,
    font: .idormFont(.medium, size: 14)
  )
  
  private let titleLabel = UIFactory.label(
    "룸메이트 매칭을 위한 기본정보를 알려주세요!",
    textColor: .idorm_gray_300,
    font: .idormFont(.bold, size: 12)
  )
  
  private let dormLabel = UIFactory.label(
    "기숙사",
    textColor: .black,
    font: .idormFont(.medium, size: 16)
  )
  
  private let genderLabel = UIFactory.label(
    "성별",
    textColor: .black,
    font: .idormFont(.medium, size: 16)
  )
  
  private let periodLabel = UIFactory.label(
    "입사기간",
    textColor: .black,
    font: .idormFont(.medium, size: 16)
  )
  
  private let habitLabel = UIFactory.label(
    "내 습관",
    textColor: .black,
    font: .idormFont(.medium, size: 16)
  )
  
  private let ageLabel = UIFactory.label(
    "나이",
    textColor: .black,
    font: .idormFont(.medium, size: 16)
  )
  
  private let habitDescriptionLabel = UIFactory.label(
    "불호요소가 있는 내 습관을 미리 알려주세요.",
    textColor: .idorm_gray_300,
    font: .idormFont(.bold, size: 12)
  )
  
  private let ageDescriptionLabel = UIFactory.label(
    "살",
    textColor: .idorm_gray_300,
    font: .idormFont(.bold, size: 12)
  )
  
  private var floatyBottomView: FloatyBottomView!
  private let contentView = UIView()
  
  private let dorm1Button = OnboardingButton("1 기숙사")
  private let dorm2Button = OnboardingButton("2 기숙사")
  private let dorm3Button = OnboardingButton("3 기숙사")
  private let maleButton = OnboardingButton("남성")
  private let femaleButton = OnboardingButton("여성")
  private let period16Button = OnboardingButton("16 주")
  private let period24Button = OnboardingButton("24 주")
  private let snoreButton = OnboardingButton("코골이")
  private let grindingButton = OnboardingButton("이갈이")
  private let smokingButton = OnboardingButton("흡연")
  private let allowedFoodButton = OnboardingButton("실내 음식 섭취 함")
  private let allowedEarphoneButton = OnboardingButton("이어폰 착용 안함")
  
  private let dormLine = UIFactory.view(.idorm_gray_100)
  private let genderLine = UIFactory.view(.idorm_gray_100)
  private let periodLine = UIFactory.view(.idorm_gray_100)
  private let habitLine = UIFactory.view(.idorm_gray_100)
  private let ageLine = UIFactory.view(.idorm_gray_100)
  
  
  private lazy var wakeUpInfoLabel = infoLabel("기상시간을 알려주세요.", isEssential: true)
  private let wakeUpTextField = OnboardingTextField(placeholder: "입력")
  private lazy var cleanUpInfoLabel = infoLabel("정리정돈은 얼마나 하시나요?", isEssential: true)
  private let cleanUpTextField = OnboardingTextField(placeholder: "입력")
  private lazy var showerInfoLabel = infoLabel("샤워는 주로 언제/몇 분 동안 하시나요?", isEssential: true)
  private let showerTextField = OnboardingTextField(placeholder: "입력")
  private lazy var mbtiInfoLabel = infoLabel("MBTI를 알려주세요.", isEssential: false)
  private let mbtiTextField = OnboardingTextField(placeholder: "입력")
  private lazy var chatInfoLabel = infoLabel("연락을 위한 개인 오픈채팅 링크를 알려주세요.", isEssential: true)
  private let chatTextField = OnboardingTextField(placeholder: "입력")
  private lazy var wishInfoLabel = infoLabel("미래의 룸메에게 하고 싶은 말은?", isEssential: false)
  
  private let type: Onboarding
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    chatTextField.textField.delegate = self
  }
  
  init(_ type: Onboarding) {
    self.type = type
    super.init(nibName: nil, bundle: nil)
    setupComponents()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Bind
  
  func bind(reactor: OnboardingViewReactor) {
    
    // MARK: - Action
    
    rx.viewDidLoad
      .withUnretained(self)
      .filter { $0.0.type == .modify }
      .map { _ in UserStorage.shared.matchingInfo }
      .filterNil()
      .map { OnboardingViewReactor.Action.viewDidLoad($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 1기숙사 버튼 클릭
    dorm1Button.rx.tap
      .withUnretained(self)
      .do(onNext: {
        $0.0.dorm1Button.isSelected = true
        $0.0.dorm2Button.isSelected = false
        $0.0.dorm3Button.isSelected = false
      })
      .map { _ in OnboardingViewReactor.Action.didTapDormButton(.no1) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 2기숙사 버튼 클릭
    dorm2Button.rx.tap
      .withUnretained(self)
      .do {
        $0.0.dorm1Button.isSelected = false
        $0.0.dorm2Button.isSelected = true
        $0.0.dorm3Button.isSelected = false
      }
      .map { _ in OnboardingViewReactor.Action.didTapDormButton(.no2) }
      .debug()
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 3기숙사 버튼 클릭
    dorm3Button.rx.tap
      .withUnretained(self)
      .do {
        $0.0.dorm1Button.isSelected = false
        $0.0.dorm2Button.isSelected = false
        $0.0.dorm3Button.isSelected = true
      }
      .map { _ in OnboardingViewReactor.Action.didTapDormButton(.no3) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 남자 버튼 클릭
    maleButton.rx.tap
      .withUnretained(self)
      .do {
        $0.0.maleButton.isSelected = true
        $0.0.femaleButton.isSelected = false
      }
      .map { _ in OnboardingViewReactor.Action.didTapGenderButton(.male)}
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 여자 버튼 클릭
    femaleButton.rx.tap
      .withUnretained(self)
      .do {
        $0.0.maleButton.isSelected = false
        $0.0.femaleButton.isSelected = true
      }
      .map { _ in OnboardingViewReactor.Action.didTapGenderButton(.female) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 16주 버튼 클릭
    period16Button.rx.tap
      .withUnretained(self)
      .do {
        $0.0.period16Button.isSelected = true
        $0.0.period24Button.isSelected = false
      }
      .map { _ in OnboardingViewReactor.Action.didTapJoinPeriodButton(.period_16) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 24주 버튼 클릭
    period24Button.rx.tap
      .withUnretained(self)
      .do {
        $0.0.period16Button.isSelected = false
        $0.0.period24Button.isSelected = true
      }
      .map { _ in OnboardingViewReactor.Action.didTapJoinPeriodButton(.period_24) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 흡연 버튼 클릭
    smokingButton.rx.tap
      .withUnretained(self)
      .do { $0.0.smokingButton.isSelected = !$0.0.smokingButton.isSelected }
      .map { $0.0.smokingButton.isSelected }
      .map { OnboardingViewReactor.Action.didTapHabitButton(.smoking, $0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 코골이 버튼 클릭
    snoreButton.rx.tap
      .withUnretained(self)
      .do { $0.0.snoreButton.isSelected = !$0.0.snoreButton.isSelected }
      .map { $0.0.snoreButton.isSelected }
      .map { OnboardingViewReactor.Action.didTapHabitButton(.snoring, $0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 이갈이 버튼 클릭
    grindingButton.rx.tap
      .withUnretained(self)
      .do { $0.0.grindingButton.isSelected = !$0.0.grindingButton.isSelected }
      .map { $0.0.grindingButton.isSelected }
      .map { OnboardingViewReactor.Action.didTapHabitButton(.grinding, $0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 음식 허용 버튼 클릭
    allowedFoodButton.rx.tap
      .withUnretained(self)
      .do { $0.0.allowedFoodButton.isSelected = !$0.0.allowedFoodButton.isSelected }
      .map { $0.0.allowedFoodButton.isSelected }
      .map { OnboardingViewReactor.Action.didTapHabitButton(.allowedFood, $0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 이어폰 허용 버튼 클릭
    allowedEarphoneButton.rx.tap
      .withUnretained(self)
      .do { $0.0.allowedEarphoneButton.isSelected = !$0.0.allowedEarphoneButton.isSelected }
      .map { $0.0.allowedEarphoneButton.isSelected }
      .map { OnboardingViewReactor.Action.didTapHabitButton(.allowedEarphone, $0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 나이 텍스트 반응
    ageTextField.rx.text
      .orEmpty
      .skip(1)
      .map { OnboardingViewReactor.Action.didChangeAgeTextField($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 기상시간 텍스트필드
    wakeUpTextField.textField.rx.text
      .orEmpty
      .skip(1)
      .map { OnboardingViewReactor.Action.didChangeWakeUpTextField($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 정리정돈 텍스트필드
    cleanUpTextField.textField.rx.text
      .orEmpty
      .skip(1)
      .map { OnboardingViewReactor.Action.didChangeCleanUpTextField($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 샤워시간 텍스트필드
    showerTextField.textField.rx.text
      .orEmpty
      .skip(1)
      .map { OnboardingViewReactor.Action.didChangeShowerTextField($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    chatTextField.isDefault = false
    
    // 오픈카카오 텍스트필드
    chatTextField.textField.rx.text
      .orEmpty
      .skip(1)
      .distinctUntilChanged()
      .map { OnboardingViewReactor.Action.didChangeChatTextField($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 오픈카카오 텍스트필드 포커싱 해제
    chatTextField.textField.rx.controlEvent(.editingDidEnd)
      .withUnretained(self)
      .map { $0.0.chatTextField.textField.text }
      .filterNil()
      .map { OnboardingViewReactor.Action.didEndEditingChatTextField($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // MBTI 텍스트필드
    mbtiTextField.textField.rx.text
      .orEmpty
      .skip(1)
      .map { OnboardingViewReactor.Action.didChangeMbtiTextField($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 하고싶은 말 텍스트 뷰
    wishTextView.rx.text
      .orEmpty
      .skip(1)
      .scan("") { previous, new in
        if new.count > 100 {
          return previous
        } else {
          return new
        }
      }
      .map { OnboardingViewReactor.Action.didChangeWishTextView($0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // FloatyBottomView 왼쪽 버튼
    floatyBottomView.leftButton.rx.tap
      .map { OnboardingViewReactor.Action.didTapLeftButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // FloatyBottomView 오른쪽 버튼
    floatyBottomView.rightButton.rx.tap
      .map { OnboardingViewReactor.Action.didTapRightButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 빈 공간 터치 시 키보드 내림
    scrollView.rx.tapGesture(configuration: { _, delegate in
      delegate.simultaneousRecognitionPolicy = .never
    })
    .when(.recognized)
    .withUnretained(self)
    .bind { $0.0.view.endEditing(true) }
    .disposed(by: disposeBag)
    
    // 화면 최초 접속
    rx.viewDidLoad
      .withUnretained(self)
      .filter { $0.0.type == .modify }
      .map { _ in UserStorage.shared.matchingInfo }
      .filterNil()
      .withUnretained(self)
      .bind { owner, info in
        switch info.dormCategory {
        case .no1: owner.dorm1Button.isSelected = true
        case .no2: owner.dorm2Button.isSelected = true
        case .no3: owner.dorm3Button.isSelected = true
        }
        
        switch info.gender {
        case .male: owner.maleButton.isSelected = true
        case .female: owner.femaleButton.isSelected = true
        }
        
        switch info.joinPeriod {
        case .period_16: owner.period16Button.isSelected = true
        case .period_24: owner.period24Button.isSelected = true
        }
        
        owner.snoreButton.isSelected = info.isSnoring
        owner.grindingButton.isSelected = info.isGrinding
        owner.smokingButton.isSelected = info.isSmoking
        owner.allowedFoodButton.isSelected = info.isAllowedFood
        owner.allowedEarphoneButton.isSelected = info.isWearEarphones
        owner.ageTextField.setText(String(info.age))
        owner.ageTextField.rx.text.onNext(String(info.age))
        owner.wakeUpTextField.textField.rx.text.onNext(info.wakeUpTime)
        owner.cleanUpTextField.textField.text = info.cleanUpStatus
        owner.showerTextField.textField.text = info.showerTime
        owner.mbtiTextField.textField.text = info.mbti
        owner.chatTextField.textField.text = info.openKakaoLink
        owner.wishTextView.text = info.wishText
        
        [
          owner.wakeUpTextField.checkmarkButton,
          owner.cleanUpTextField.checkmarkButton,
          owner.showerTextField.checkmarkButton,
          owner.chatTextField.checkmarkButton,
          owner.mbtiTextField.checkmarkButton
        ].forEach { $0.isHidden = false }
        
        if info.mbti == nil || info.mbti == "" {
          owner.mbtiTextField.checkmarkButton.isHidden = true
        }
      }
      .disposed(by: disposeBag)
    
    // MARK: - State
    
    // 인디케이터 애니메이션
    reactor.state
      .map { $0.isLoading }
      .bind(to: indicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    // 완료 버튼 활성화/비활성화
    reactor.state
      .map { $0.currentDriver }
      .flatMap { $0.isEnabled }
      .bind(to: floatyBottomView.rightButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    // MainVC로 이동
    reactor.state
      .map { $0.isOpenedMainVC }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let mainVC = TabBarViewController()
        mainVC.modalPresentationStyle = .fullScreen
        owner.present(mainVC, animated: true)
      }
      .disposed(by: disposeBag)
    
    // 선택초기화
    reactor.state
      .map { $0.isCleared }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        [
          owner.dorm1Button, owner.dorm2Button, owner.dorm3Button,
          owner.maleButton, owner.femaleButton,
          owner.period16Button, owner.period24Button,
          owner.smokingButton,
          owner.snoreButton,
          owner.grindingButton,
          owner.allowedFoodButton,
          owner.allowedEarphoneButton
        ]
          .forEach { $0.isSelected = false }
        
        [
          owner.wakeUpTextField.textField,
          owner.cleanUpTextField.textField,
          owner.showerTextField.textField,
          owner.chatTextField.textField,
          owner.mbtiTextField.textField,
        ]
          .forEach { $0.text = "" }
        
        [
          owner.wakeUpTextField.checkmarkButton,
          owner.cleanUpTextField.checkmarkButton,
          owner.showerTextField.checkmarkButton,
          owner.chatTextField.checkmarkButton,
          owner.mbtiTextField.checkmarkButton
        ]
          .forEach { $0.isHidden = true }
        
        owner.wishTextView.text = ""
        owner.ageTextField.clearOTP()
      }
      .disposed(by: disposeBag)
    
    // RootVC로 이동
    reactor.state
      .map { $0.isOpenedRootVC }
      .filter { $0 }
      .withUnretained(self)
      .bind { $0.0.navigationController?.popToRootViewController(animated: true) }
      .disposed(by: disposeBag)
    
    // OnboardingDetailVC로 이동
    reactor.state
      .map { $0.isOpenedOnboardingDetailVC }
      .filter { $0.0 }
      .withUnretained(self)
      .bind { owner, member in
        let onboardingDetailVC = OnboardingDetailViewController(member.1, type: owner.type)
        onboardingDetailVC.reactor = OnboardingDetailViewReactor(owner.type)
        owner.navigationController?.pushViewController(onboardingDetailVC, animated: true)
      }
      .disposed(by: disposeBag)
    
    // ChatTextField 모서리 색상
    reactor.state
      .map { $0.currentChatBorderColor }
      .map { $0.cgColor }
      .bind(to: chatTextField.layer.rx.borderColor)
      .disposed(by: disposeBag)
    
    // ChatTextField 체크마크 숨김
    reactor.state
      .map { $0.isHiddenChatTfCheckmark }
      .bind(to: chatTextField.checkmarkButton.rx.isHidden)
      .disposed(by: disposeBag)
    
    // ChatDescriptionLabel 텍스트 색상
    reactor.state
      .map { $0.currentChatDescriptionTextColor }
      .bind(to: chatDescriptionLabel.rx.textColor)
      .disposed(by: disposeBag)
    
    // 오류 팝업 창
    reactor.state
      .map { $0.isOpenedPopup }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let popup = BasicPopup(contents:
          """
          올바른 형식의 링크가 아닙니다.
          open.kakao 형식을 포함했는지 확인해주세요.
          """
        )
        popup.modalPresentationStyle = .overFullScreen
        owner.present(popup, animated: false)
      }
      .disposed(by: disposeBag)
    
    // 현재 하고싶은 말 TextView 글자 수
    reactor.state
      .map { $0.currentWishTextCount }
      .map { String($0) }
      .bind(to: currentLengthLabel.rx.text)
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  private func setupComponents() {
    switch type {
    case .initial:
      self.floatyBottomView = FloatyBottomView(.jump)
    case .main:
      self.floatyBottomView = FloatyBottomView(.reset)
    case .modify:
      self.floatyBottomView = FloatyBottomView(.reset)
    }
    self.floatyBottomView.rightButton.isEnabled = false
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      scrollView,
      floatyBottomView,
      indicator
    ]
      .forEach { view.addSubview($0) }
    
    scrollView.addSubview(contentView)
    
    [
      titleLabel,
      dormLabel, dormStack, dormLine,
      genderLabel, genderStack, genderLine,
      periodLabel, periodStack, periodLine,
      habitLabel, habitStack1, habitStack2, habitLine, habitDescriptionLabel,
      ageLabel, ageDescriptionLabel, ageTextField, ageLine,
      wakeUpInfoLabel, wakeUpTextField,
      cleanUpInfoLabel, cleanUpTextField,
      showerInfoLabel, showerTextField,
      mbtiInfoLabel, mbtiTextField,
      chatInfoLabel, chatTextField, chatDescriptionLabel,
      wishInfoLabel, wishTextView,
      currentLengthLabel, maxLengthLabel
    ]
      .forEach { contentView.addSubview($0) }
  }
  
  override func setupStyles() {
    navigationController?.setNavigationBarHidden(false, animated: true)
    contentView.backgroundColor = .white
    view.backgroundColor = .white
    
    switch type {
    case .main, .modify:
      navigationItem.title = "매칭 이미지 관리"
    case .initial:
      navigationItem.title = "내 정보 입력"
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    floatyBottomView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
      make.height.equalTo(76)
    }
    
    scrollView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.bottom.equalTo(floatyBottomView.snp.top)
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalTo(view.frame.width)
    }
    
    titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalToSuperview().inset(20)
    }
    
    dormLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(titleLabel.snp.bottom).offset(16)
    }
    
    dormStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(dormLabel.snp.bottom).offset(10)
    }
    
    dormLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(dormStack.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    genderLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(dormLine.snp.bottom).offset(16)
    }
    
    genderStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(genderLabel.snp.bottom).offset(10)
    }
    
    genderLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(genderStack.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    periodLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(genderLine.snp.bottom).offset(16)
    }
    
    periodStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(periodLabel.snp.bottom).offset(10)
    }
    
    periodLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(periodStack.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    habitLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(periodLine.snp.bottom).offset(16)
    }
    
    habitDescriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(habitLabel.snp.bottom)
      make.leading.equalToSuperview().inset(25)
    }
    
    habitStack1.snp.makeConstraints { make in
      make.top.equalTo(habitDescriptionLabel.snp.bottom).offset(12)
      make.leading.equalToSuperview().inset(25)
    }
    
    habitStack2.snp.makeConstraints { make in
      make.top.equalTo(habitStack1.snp.bottom).offset(10)
      make.leading.equalToSuperview().inset(25)
    }
    
    habitLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(habitStack2.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    ageLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(habitLine.snp.bottom).offset(16)
    }
    
    ageTextField.snp.makeConstraints { make in
      make.top.equalTo(ageLabel.snp.bottom).offset(10)
      make.leading.equalToSuperview().inset(25)
      make.width.equalTo(90)
      make.height.equalTo(33)
    }
    
    ageDescriptionLabel.snp.makeConstraints { make in
      make.centerY.equalTo(ageTextField)
      make.leading.equalTo(ageTextField.snp.trailing).offset(8)
    }
    
    ageLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(ageTextField.snp.bottom).offset(16)
      make.height.equalTo(1)
    }
    
    wakeUpInfoLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(ageLine.snp.bottom).offset(16)
    }
    
    wakeUpTextField.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(wakeUpInfoLabel.snp.bottom).offset(8)
      make.height.equalTo(50)
    }
    
    cleanUpInfoLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(wakeUpTextField.snp.bottom).offset(32)
    }
    
    cleanUpTextField.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(cleanUpInfoLabel.snp.bottom).offset(8)
      make.height.equalTo(50)
    }
    
    showerInfoLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(cleanUpTextField.snp.bottom).offset(32)
    }
    
    showerTextField.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(showerInfoLabel.snp.bottom).offset(8)
      make.height.equalTo(50)
    }
    
    chatInfoLabel.snp.makeConstraints { make in
      make.top.equalTo(showerTextField.snp.bottom).offset(32)
      make.leading.equalToSuperview().inset(25)
    }
    
    chatTextField.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(chatInfoLabel.snp.bottom).offset(8)
      make.height.equalTo(50)
    }
    
    chatDescriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(chatTextField.snp.bottom).offset(4)
      make.leading.equalToSuperview().inset(25)
    }
    
    mbtiInfoLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(chatDescriptionLabel.snp.bottom).offset(36)
    }
    
    mbtiTextField.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(mbtiInfoLabel.snp.bottom).offset(8)
      make.height.equalTo(50)
    }
    
    wishInfoLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(mbtiTextField.snp.bottom).offset(32)
    }
    
    wishTextView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(wishInfoLabel.snp.bottom).offset(8)
      make.bottom.equalToSuperview().inset(90)
    }
    
    maxLengthLabel.snp.makeConstraints { make in
      make.centerY.equalTo(wishInfoLabel)
      make.trailing.equalToSuperview().inset(25)
    }
    
    currentLengthLabel.snp.makeConstraints { make in
      make.centerY.equalTo(wishInfoLabel)
      make.trailing.equalTo(maxLengthLabel.snp.leading).offset(-4)
    }
  }
  
  // MARK: - Helpers
  
  /// Description에 대한 Label을 만들어주는 메서드입니다.
  func infoLabel(_ title: String, isEssential: Bool) -> UILabel {
    let lb = UIFactory.label(
      title,
      textColor: .idorm_gray_400,
      font: .idormFont(.medium, size: 14)
    )
    
    if isEssential {
      let trailingLb = UIFactory.label(
        "(필수)",
        textColor: .idorm_blue,
        font: .idormFont(.medium, size: 14)
      )
      
      lb.addSubview(trailingLb)
      trailingLb.snp.makeConstraints { make in
        make.centerY.equalToSuperview()
        make.leading.equalTo(lb.snp.trailing).offset(8)
      }
    }
    
    return lb
  }
  
  /// 클립보드에 있는 텍스트를 URL형식의 String으로 변환해주는 메서드입니다.
  func extractLinkFromText(_ text: String) -> String? {
    let pattern = "(?i)https?://(?:www\\.)?\\S+(?:/|\\b)"
    
    guard let regex = try? NSRegularExpression(
      pattern: pattern,
      options: []
    ) else {
      return nil
    }
    
    if let result = regex.firstMatch(
      in: text,
      options: [],
      range: NSRange(location: 0, length: text.utf16.count)
    ) {
      let url = (text as NSString).substring(with: result.range)
      return url
    }
    return nil
  }
}

// MARK: - Delegate

extension OnboardingViewController: UITextFieldDelegate {
  // 오픈채팅 링크 텍스트필드의 클립보드를 제어하기 위한 Delegate 메서드
  func textField(
    _ textField: UITextField,
    shouldChangeCharactersIn range: NSRange,
    replacementString string: String
  ) -> Bool {
    if textField == chatTextField.textField {
      // 오픈채팅 텍스트필드인 경우 클립보드의 문자열에서 URL 추출하여 붙여넣기
      if let clipboardText = UIPasteboard.general.string {
        if let url = extractLinkFromText(clipboardText) {
          textField.text = url
          reactor?.action.onNext(.didChangeChatTextField(url))
          return false
        }
        return true
      }
    } else {
      // 다른 textField인 경우 그대로 붙여넣기
      return true
    }
    return true
  }
}

