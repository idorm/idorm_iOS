import UIKit

import SnapKit
import Then
import CHIOTPField
import RSKGrowingTextView
import RxSwift
import RxCocoa
import RxGesture
import RxAppState

final class OnboardingViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let titleLabel = OnboardingUtilities.descriptionLabel("룸메이트 매칭을 위한 기본정보를 알려주세요!")
  private var floatyBottomView: FloatyBottomView!
  
  private let indicator = UIActivityIndicatorView().then {
    $0.color = .gray
  }
  
  private let scrollView = UIScrollView().then {
    $0.keyboardDismissMode = .onDrag
  }
  
  private let contentView = UIView()
  
  private let dormLabel = OnboardingUtilities.titleLabel(text: "기숙사")
  private let dorm1Button = OnboardingUtilities.basicButton(title: "1 기숙사")
  private let dorm2Button = OnboardingUtilities.basicButton(title: "2 기숙사")
  private let dorm3Button = OnboardingUtilities.basicButton(title: "3 기숙사")
  private let dormLine = OnboardingUtilities.separatorLine()
  
  private lazy var dormStack = UIStackView().then { stack in
    [dorm1Button, dorm2Button, dorm3Button]
      .forEach { stack.addArrangedSubview($0) }
    stack.spacing = 12
  }
  
  private let genderLabel = OnboardingUtilities.titleLabel(text: "성별")
  private let maleButton = OnboardingUtilities.basicButton(title: "남성")
  private let femaleButton = OnboardingUtilities.basicButton(title: "여성")
  private let genderLine = OnboardingUtilities.separatorLine()
  
  private lazy var genderStack = UIStackView().then { stack in
    [maleButton, femaleButton]
      .forEach { stack.addArrangedSubview($0) }
    stack.spacing = 12
  }
  
  private let periodLabel = OnboardingUtilities.titleLabel(text: "입사 기간")
  private let period16Button = OnboardingUtilities.basicButton(title: "16 주")
  private let period24Button = OnboardingUtilities.basicButton(title: "24 주")
  private let periodLine = OnboardingUtilities.separatorLine()
  
  private lazy var periodStack = UIStackView().then { stack in
    [period16Button, period24Button]
      .forEach { stack.addArrangedSubview($0) }
    stack.spacing = 12
  }
  
  private let habitDescriptionLabel = OnboardingUtilities.descriptionLabel("불호요소가 있는 내 습관을 미리 알려주세요.")
  private let habitLabel = OnboardingUtilities.titleLabel(text: "내 습관")
  private let snoreButton = OnboardingUtilities.basicButton(title: "코골이")
  private let grindingButton = OnboardingUtilities.basicButton(title: "이갈이")
  private let smokingButton = OnboardingUtilities.basicButton(title: "흡연")
  private let allowedFoodButton = OnboardingUtilities.basicButton(title: "실내 음식 섭취 함")
  private let allowedEarphoneButton = OnboardingUtilities.basicButton(title: "이어폰 착용 안함")
  private let habitLine = OnboardingUtilities.separatorLine()
  
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
  
  private let ageTextField = CHIOTPFieldTwo().then {
    $0.numberOfDigits = 2
    $0.borderColor = .idorm_gray_200
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14)
    $0.cornerRadius = 10
    $0.spacing = 2
  }
  
  private let ageDescriptionLabel = OnboardingUtilities.descriptionLabel("살")
  private let ageLabel = OnboardingUtilities.titleLabel(text: "나이")
  private let ageLine = OnboardingUtilities.separatorLine()
  
  private var viewModel: OnboardingViewModel
  private let vcType: OnboardingVCTypes.OnboardingVCType
  
  private let wakeUpInfoLabel = OnboardingUtilities.infoLabel("기상시간을 알려주세요.", isEssential: true)
  private let wakeUpTextField = OnboardingTextField(placeholder: "입력")
  
  private let cleanUpInfoLabel = OnboardingUtilities.infoLabel("정리정돈은 얼마나 하시나요?", isEssential: true)
  private let cleanUpTextField = OnboardingTextField(placeholder: "입력")
  
  private let showerInfoLabel = OnboardingUtilities.infoLabel("샤워는 주로 언제/몇 분 동안 하시나요?", isEssential: true)
  private let showerTextField = OnboardingTextField(placeholder: "입력")
  
  private let mbtiInfoLabel = OnboardingUtilities.infoLabel("MBTI를 알려주세요.", isEssential: false)
  private let mbtiTextField = OnboardingTextField(placeholder: "입력")
  
  private let chatInfoLabel = OnboardingUtilities.infoLabel("연락을 위한 개인 오픈채팅 링크를 알려주세요.", isEssential: true)
  private let chatTextField = OnboardingTextField(placeholder: "입력")
  
  private let wishInfoLabel = OnboardingUtilities.infoLabel("미래의 룸메에게 하고 싶은 말은?", isEssential: false)
  private let wishTextView = RSKGrowingTextView().then {
    $0.attributedPlaceholder = NSAttributedString(string: "입력", attributes: [NSAttributedString.Key.font: UIFont.init(name: MyFonts.regular.rawValue, size: 14) ?? 0, NSAttributedString.Key.foregroundColor: UIColor.idorm_gray_300])
    $0.font = .init(name: MyFonts.regular.rawValue, size: 14)
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
  
  private let maxLengthLabel = UILabel().then {
    $0.text = "/ 100 pt"
    $0.textColor = .idorm_gray_300
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14)
  }
  
  private let currentLengthLabel = UILabel().then {
    $0.text = "0"
    $0.textColor = .idorm_blue
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14)
  }
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    setupFloatyBottomView()
    super.viewDidLoad()
  }
  
  init(_ onboardingVCType: OnboardingVCTypes.OnboardingVCType) {
    self.viewModel = OnboardingViewModel(onboardingVCType)
    self.vcType = onboardingVCType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(scrollView)
    view.addSubview(floatyBottomView)
    view.addSubview(indicator)
    scrollView.addSubview(contentView)
    
    [
      titleLabel, dormLabel, dormStack, dormLine, genderLabel, genderStack, genderLine, periodLabel, periodStack, periodLine, habitLabel, habitStack1, habitStack2, habitLine, habitDescriptionLabel, ageLabel, ageDescriptionLabel, ageTextField, ageLine, wakeUpInfoLabel, wakeUpTextField, cleanUpInfoLabel, cleanUpTextField, showerInfoLabel, showerTextField, mbtiInfoLabel, mbtiTextField, chatInfoLabel, chatTextField, wishInfoLabel, wishTextView, currentLengthLabel, maxLengthLabel
    ].forEach { contentView.addSubview($0) }
  }
  
  override func setupStyles() {
    super.setupStyles()
    contentView.backgroundColor = .white
    view.backgroundColor = .white
    
    switch vcType {
    case .initial2, .update:
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
    
    mbtiInfoLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(chatTextField.snp.bottom).offset(32)
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
  
  private func setupFloatyBottomView() {
    switch vcType {
    case .initial:
      self.floatyBottomView = FloatyBottomView(.jump)
    case .initial2:
      self.floatyBottomView = FloatyBottomView(.reset)
    case .update:
      self.floatyBottomView = FloatyBottomView(.reset)
    }
    self.floatyBottomView.rightButton.isEnabled = false
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // 텍스트뷰 글자수 제한
    wishTextView.rx.text
      .orEmpty
      .scan("") { $1.count > 100 ? $0 : $1 }
      .bind(to: wishTextView.rx.text)
      .disposed(by: disposeBag)
    
    // MARK: - Input
    
    // 매칭 정보 최초 설정
    rx.viewWillAppear
      .take(1)
      .map { _ in Void() }
      .bind(to: viewModel.input.viewDidLoad)
      .disposed(by: disposeBag)
    
    // 1기숙사 버튼 클릭
    dorm1Button.rx.tap
      .map { Dormitory.no1 }
      .bind(to: viewModel.input.dormButtonDidTap)
      .disposed(by: disposeBag)
    
    // 2기숙사 버튼 클릭
    dorm2Button.rx.tap
      .map { Dormitory.no2 }
      .bind(to: viewModel.input.dormButtonDidTap)
      .disposed(by: disposeBag)
    
    // 3기숙사 버튼 클릭
    dorm3Button.rx.tap
      .map { Dormitory.no3 }
      .bind(to: viewModel.input.dormButtonDidTap)
      .disposed(by: disposeBag)
    
    // 남자 버튼 클릭
    maleButton.rx.tap
      .map { Gender.male }
      .bind(to: viewModel.input.genderButtonDidTap)
      .disposed(by: disposeBag)
    
    // 여자 버튼 클릭
    femaleButton.rx.tap
      .map { Gender.female }
      .bind(to: viewModel.input.genderButtonDidTap)
      .disposed(by: disposeBag)
    
    // 16주 버튼 클릭
    period16Button.rx.tap
      .map { JoinPeriod.period_16 }
      .bind(to: viewModel.input.joinPeriodButtonDidTap)
      .disposed(by: disposeBag)
    
    // 24주 버튼 클릭
    period24Button.rx.tap
      .map { JoinPeriod.period_24 }
      .bind(to: viewModel.input.joinPeriodButtonDidTap)
      .disposed(by: disposeBag)
    
    // 코골이 버튼 클릭
    snoreButton.rx.tap
      .withUnretained(self)
      .map { $0.0 }
      .map { !($0.snoreButton.isSelected) }
      .bind(to: viewModel.input.isSnoringButtonDidTap)
      .disposed(by: disposeBag)
    
    // 이갈이 버튼 클릭
    grindingButton.rx.tap
      .withUnretained(self)
      .map { $0.0 }
      .map { !($0.grindingButton.isSelected) }
      .bind(to: viewModel.input.isGrindingButtonDidTap)
      .disposed(by: disposeBag)
    
    // 흡연 버튼 클릭
    smokingButton.rx.tap
      .withUnretained(self)
      .map { $0.0 }
      .map { !($0.smokingButton.isSelected) }
      .bind(to: viewModel.input.isSmokingButtonDidTap)
      .disposed(by: disposeBag)
    
    // 음식 버튼 클릭
    allowedFoodButton.rx.tap
      .withUnretained(self)
      .map { $0.0 }
      .map { !($0.allowedFoodButton.isSelected) }
      .bind(to: viewModel.input.isAllowedFoodButtonDidTap)
      .disposed(by: disposeBag)
    
    // 이어폰 버튼 클릭
    allowedEarphoneButton.rx.tap
      .withUnretained(self)
      .map { $0.0 }
      .map { !($0.allowedEarphoneButton.isSelected) }
      .bind(to: viewModel.input.isAllowedEarphoneButtonDidTap)
      .disposed(by: disposeBag)
    
    // 나이 텍스트 반응
    Observable<Int>
      .interval(.microseconds(100000), scheduler: MainScheduler.instance)
      .withUnretained(self)
      .map { $0.0 }
      .map { $0.ageTextField.text ?? "" }
      .bind(to: viewModel.input.ageTextFieldDidChange)
      .disposed(by: disposeBag)
    
    // 기상시간 텍스트필드 반응
    wakeUpTextField.textField.rx.text
      .orEmpty
      .bind(to: viewModel.input.wakeUpTextFieldDidChange)
      .disposed(by: disposeBag)
    
    // 정리정돈 텍스트필드 반응
    cleanUpTextField.textField.rx.text
      .orEmpty
      .bind(to: viewModel.input.cleanUpTextFieldDidChange)
      .disposed(by: disposeBag)
    
    // 샤워시간 텍스트필드 반응
    showerTextField.textField.rx.text
      .orEmpty
      .bind(to: viewModel.input.showerTimeTextFieldDidChange)
      .disposed(by: disposeBag)
    
    // 오픈채팅 텍스트필드 반응
    chatTextField.textField.rx.text
      .orEmpty
      .bind(to: viewModel.input.kakaoLinkTextFieldDidChange)
      .disposed(by: disposeBag)
    
    // mbti 텍스트필드 반응
    mbtiTextField.textField.rx.text
      .orEmpty
      .bind(to: viewModel.input.mbtiTextFieldDidChange)
      .disposed(by: disposeBag)
    
    // 하고싶은 말 텍스트뷰 반응
    wishTextView.rx.text
      .orEmpty
      .bind(to: viewModel.input.wishTextViewDidChange)
      .disposed(by: disposeBag)
    
    // 스크롤 뷰 터치
    scrollView.rx.tapGesture(configuration: { _, delegate in
      delegate.simultaneousRecognitionPolicy = .never
    })
    .map { _ in Void() }
    .bind(to: viewModel.input.scrollViewDidTap)
    .disposed(by: disposeBag)
    
    // 하단 뷰 왼쪽 버튼 클릭
    floatyBottomView.leftButton.rx.tap
      .bind(to: viewModel.input.leftButtonDidTap)
      .disposed(by: disposeBag)
    
    // 하단 뷰 오른쪽 버튼 클릭
    floatyBottomView.rightButton.rx.tap
      .bind(to: viewModel.input.rightButtonDidTap)
      .disposed(by: disposeBag)
    
    // MARK: - Output
    
    // 기숙사 버튼 토글
    viewModel.output.toggleDormButton
      .withUnretained(self)
      .bind(onNext: { owner, dorm in
        switch dorm {
        case .no1:
          owner.dorm1Button.isSelected = true
          owner.dorm2Button.isSelected = false
          owner.dorm3Button.isSelected = false
        case .no2:
          owner.dorm1Button.isSelected = false
          owner.dorm2Button.isSelected = true
          owner.dorm3Button.isSelected = false
        case .no3:
          owner.dorm1Button.isSelected = false
          owner.dorm2Button.isSelected = false
          owner.dorm3Button.isSelected = true
        }
      })
      .disposed(by: disposeBag)
    
    // 성별 버튼 토글
    viewModel.output.toggleGenderButton
      .withUnretained(self)
      .bind(onNext: { owner, gender in
        switch gender {
        case .male:
          owner.maleButton.isSelected = true
          owner.femaleButton.isSelected = false
        case .female:
          owner.maleButton.isSelected = false
          owner.femaleButton.isSelected = true
        }
      })
      .disposed(by: disposeBag)
    
    // 입사 기간 버튼 토글
    viewModel.output.toggleJoinPeriodButton
      .withUnretained(self)
      .bind(onNext: { owner, joinPeriod in
        switch joinPeriod {
        case .period_16:
          owner.period16Button.isSelected = true
          owner.period24Button.isSelected = false
        case .period_24:
          owner.period16Button.isSelected = false
          owner.period24Button.isSelected = true
        }
      })
      .disposed(by: disposeBag)
    
    // 코골이 버튼 토글
    viewModel.output.toggleIsSnoringButton
      .bind(to: snoreButton.rx.isSelected)
      .disposed(by: disposeBag)
    
    // 이갈이 버튼 토글
    viewModel.output.toggleIsGrindingButton
      .bind(to: grindingButton.rx.isSelected)
      .disposed(by: disposeBag)
    
    // 흡연 버튼 토글
    viewModel.output.toggleIsSmokingButton
      .bind(to: smokingButton.rx.isSelected)
      .disposed(by: disposeBag)
    
    // 음식 버튼 토글
    viewModel.output.toggleIsAllowedFoodButton
      .bind(to: allowedFoodButton.rx.isSelected)
      .disposed(by: disposeBag)
    
    // 이어폰 버튼 토글
    viewModel.output.toggleIsAllowedEarphoneButton
      .bind(to: allowedEarphoneButton.rx.isSelected)
      .disposed(by: disposeBag)
    
    // 현재 텍스트뷰 글자 수
    viewModel.output.currentTextViewLength
      .map { String($0) }
      .bind(to: currentLengthLabel.rx.text)
      .disposed(by: disposeBag)
    
    // 완료 버튼 활성화
    viewModel.output.isEnabledConfirmButton
      .bind(to: floatyBottomView.rightButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    // 로딩 인디케이터 제어
    viewModel.output.isLoading
      .bind(to: indicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    // 화면 인터렉션 제어
    viewModel.output.isLoading
      .map { !$0 }
      .bind(to: view.rx.isUserInteractionEnabled)
      .disposed(by: disposeBag)
    
    // 입력 초기화
    viewModel.output.reset
      .debug()
      .withUnretained(self)
      .bind(onNext: { owner, _ in
        [
          owner.dorm1Button,
          owner.dorm2Button,
          owner.dorm3Button,
          owner.maleButton,
          owner.femaleButton,
          owner.period16Button,
          owner.period24Button,
          owner.snoreButton,
          owner.grindingButton,
          owner.smokingButton,
          owner.allowedFoodButton,
          owner.allowedEarphoneButton
        ].forEach { $0.isSelected = false }
        
        [
          owner.wakeUpTextField,
          owner.cleanUpTextField,
          owner.showerTextField,
          owner.mbtiTextField,
          owner.chatTextField
        ].forEach {
          $0.textField.text = ""
          $0.checkmarkButton.isHidden = true
        }
        
        owner.ageTextField.text = ""
        owner.ageTextField.labels.forEach { $0.text = "" }
        owner.wishTextView.text = ""
        owner.floatyBottomView.rightButton.isEnabled = false
      })
      .disposed(by: disposeBag)
    
    // 저장되어 있는 온보딩 셋업
    viewModel.output.setupUI
      .withUnretained(self)
      .bind(onNext: { owner, info in
        switch info.dormNum {
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
        owner.ageTextField.text = String(info.age)
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
      })
      .disposed(by: disposeBag)
    
    // 에디팅 강제 종료
    viewModel.output.endEditing
      .withUnretained(self)
      .map { $0.0 }
      .bind(onNext: {
        $0.view.endEditing(true)
      })
      .disposed(by: disposeBag)
  
    // 메인페이지
    viewModel.output.presentMainVC
      .withUnretained(self)
      .bind(onNext: { owner, _ in
        let viewController = TabBarController()
        viewController.modalPresentationStyle = .fullScreen
        owner.present(viewController, animated: true)
      })
      .disposed(by: disposeBag)

    // RootVC
    viewModel.output.pushToRootVC
      .withUnretained(self)
      .bind(onNext: { owner, _ in
        owner.navigationController?.popToRootViewController(animated: true)
      })
      .disposed(by: disposeBag)
    
    // OnboardingDetailVC
    viewModel.output.pushToOnboardingDetailVC
      .withUnretained(self)
      .bind(onNext: { owner, matchingMember in
        let viewController = OnboardingDetailViewController(matchingMember, vcType: .initilize)
        owner.navigationController?.pushViewController(viewController, animated: true)
      })
      .disposed(by: disposeBag)
  }
}


// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct OnboardingVC_PreView: PreviewProvider {
  static var previews: some View {
    OnboardingViewController(.initial).toPreview()
  }
}
#endif

