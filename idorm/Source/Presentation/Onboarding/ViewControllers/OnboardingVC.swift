import UIKit

import SnapKit
import Then
import CHIOTPField
import RSKGrowingTextView
import RxSwift
import RxCocoa

final class OnboardingViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let titleLabel = OnboardingUtilities.descriptionLabel("룸메이트 매칭을 위한 기본정보를 알려주세요!")
  private var floatyBottomView: FloatyBottomView!
  private let viewModel = OnboardingViewModel()
  private let onboardingVCType: OnboardingVCType
  
  // MARK: - ScrollView
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  
  // MARK: - Dorm
  private let dormLabel = OnboardingUtilities.titleLabel(text: "기숙사")
  private let dorm1Button = OnboardingUtilities.basicButton(title: "1 기숙사")
  private let dorm2Button = OnboardingUtilities.basicButton(title: "2 기숙사")
  private let dorm3Button = OnboardingUtilities.basicButton(title: "3 기숙사")
  private let dormLine = OnboardingUtilities.separatorLine()
  private var dormStack: UIStackView!
  
  // MARK: - Gender
  private let genderLabel = OnboardingUtilities.titleLabel(text: "성별")
  private let maleButton = OnboardingUtilities.basicButton(title: "남성")
  private let femaleButton = OnboardingUtilities.basicButton(title: "여성")
  private let genderLine = OnboardingUtilities.separatorLine()
  private var genderStack: UIStackView!
  
  // MARK: - Period
  private let periodLabel = OnboardingUtilities.titleLabel(text: "입사 기간")
  private let period16Button = OnboardingUtilities.basicButton(title: "16 주")
  private let period24Button = OnboardingUtilities.basicButton(title: "24 주")
  private let periodLine = OnboardingUtilities.separatorLine()
  private var periodStack: UIStackView!
  
  // MARK: - Habit
  private let habitDescriptionLabel = OnboardingUtilities.descriptionLabel("불호요소가 있는 내 습관을 미리 알려주세요.")
  private let habitLabel = OnboardingUtilities.titleLabel(text: "내 습관")
  private let snoreButton = OnboardingUtilities.basicButton(title: "코골이")
  private let grindingButton = OnboardingUtilities.basicButton(title: "이갈이")
  private let smokingButton = OnboardingUtilities.basicButton(title: "흡연")
  private let allowedFoodButton = OnboardingUtilities.basicButton(title: "실내 음식 섭취 함")
  private let allowedEarphoneButton = OnboardingUtilities.basicButton(title: "이어폰 착용 안함")
  private let habitLine = OnboardingUtilities.separatorLine()
  private var habitStack1: UIStackView!
  private var habitStack2: UIStackView!
  
  // MARK: - Age
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
  
  // MARK: - WakeUp
  private let wakeUpInfoLabel = OnboardingUtilities.infoLabel("기상시간을 알려주세요.", isEssential: true)
  private let wakeUpTextField = OnboardingTextField(placeholder: "입력")
  
  // MARK: - CleanUp
  private let cleanUpInfoLabel = OnboardingUtilities.infoLabel("정리정돈은 얼마나 하시나요?", isEssential: true)
  private let cleanUpTextField = OnboardingTextField(placeholder: "입력")
  
  // MARK: - Shower
  private let showerInfoLabel = OnboardingUtilities.infoLabel("샤워는 주로 언제/몇 분 동안 하시나요?", isEssential: true)
  private let showerTextField = OnboardingTextField(placeholder: "입력")
  
  // MARK: - MBTI
  private let mbtiInfoLabel = OnboardingUtilities.infoLabel("MBTI를 알려주세요.", isEssential: false)
  private let mbtiTextField = OnboardingTextField(placeholder: "입력")
  
  // MARK: - OpenChat
  private let chatInfoLabel = OnboardingUtilities.infoLabel("룸메와 연락을 위한 개인 오픈채팅 링크를 알려주세요.", isEssential: false)
  private let chatTextField = OnboardingTextField(placeholder: "입력")
  
  // MARK: - WishText
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
  
  private let letterNumLabel = UILabel().then {
    $0.textColor = .idorm_gray_300
    $0.font = .init(name: MyFonts.medium.rawValue, size: 14)
  }
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    setupStackView()
    setupFloatyBottomView()
    setupScrollView()
    super.viewDidLoad()
  }
  
  init(_ onboardingVCType: OnboardingVCType) {
    self.onboardingVCType = onboardingVCType
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
    scrollView.addSubview(contentView)
    
    [titleLabel, dormLabel, dormStack, dormLine, genderLabel, genderStack, genderLine, periodLabel, periodStack, periodLine, habitLabel, habitStack1, habitStack2, habitLine, habitDescriptionLabel, ageLabel, ageDescriptionLabel, ageTextField, ageLine, wakeUpInfoLabel, wakeUpTextField, cleanUpInfoLabel, cleanUpTextField, showerInfoLabel, showerTextField, mbtiInfoLabel, mbtiTextField, chatInfoLabel, chatTextField, wishInfoLabel, wishTextView, letterNumLabel]
      .forEach { contentView.addSubview($0) }
  }
  
  override func setupStyles() {
    super.setupStyles()
    contentView.backgroundColor = .white
    view.backgroundColor = .white
    
    switch onboardingVCType {
    case .mainPage_FirstTime, .update:
      navigationItem.title = "매칭 이미지 관리"
    case .firstTime:
      navigationItem.title = "내 정보 입력"
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
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
    
    mbtiInfoLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(showerTextField.snp.bottom).offset(32)
    }
    
    mbtiTextField.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(mbtiInfoLabel.snp.bottom).offset(8)
      make.height.equalTo(50)
    }
    
    chatInfoLabel.snp.makeConstraints { make in
      make.top.equalTo(mbtiTextField.snp.bottom).offset(32)
      make.leading.equalToSuperview().inset(25)
    }
    
    chatTextField.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(chatInfoLabel.snp.bottom).offset(8)
      make.height.equalTo(50)
    }
    
    wishInfoLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(25)
      make.top.equalTo(chatTextField.snp.bottom).offset(32)
    }
    
    wishTextView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(25)
      make.top.equalTo(wishInfoLabel.snp.bottom).offset(8)
      make.bottom.equalToSuperview().inset(90)
    }
    
    letterNumLabel.snp.makeConstraints { make in
      make.centerY.equalTo(wishInfoLabel)
      make.trailing.equalToSuperview().inset(25)
    }
  }
  
  private func setupStackView() {
    let dormStack = UIStackView(arrangedSubviews: [ dorm1Button, dorm2Button, dorm3Button ])
    dormStack.spacing = 12
    self.dormStack = dormStack
    
    let genderStack = UIStackView(arrangedSubviews: [ maleButton, femaleButton ])
    genderStack.spacing = 12
    self.genderStack = genderStack
    
    let periodStack = UIStackView(arrangedSubviews: [ period16Button, period24Button ])
    periodStack.spacing = 12
    self.periodStack = periodStack
    
    let habitStack1 = UIStackView(arrangedSubviews: [ snoreButton, grindingButton, smokingButton ])
    let habitStack2 = UIStackView(arrangedSubviews: [ allowedFoodButton, allowedEarphoneButton ])
    habitStack1.spacing = 12
    habitStack2.spacing = 12
    self.habitStack1 = habitStack1
    self.habitStack2 = habitStack2
  }
  
  private func setupFloatyBottomView() {
    switch onboardingVCType {
    case .firstTime:
      self.floatyBottomView = FloatyBottomView(.jump)
    case .mainPage_FirstTime:
      self.floatyBottomView = FloatyBottomView(.reset)
    case .update:
      self.floatyBottomView = FloatyBottomView(.back)
    }
    self.floatyBottomView.confirmButton.isEnabled = false
  }
  
  private func setupScrollView() {
    scrollView.keyboardDismissMode = .onDrag
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapScrollView))
    tapGesture.cancelsTouchesInView = false
    scrollView.addGestureRecognizer(tapGesture)
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // MARK: - Input
    
    // 텍스트뷰 글자수 제한
    wishTextView.rx.text
      .orEmpty
      .scan("") { previous, new in
        if new.count > 100 {
          return previous
        } else {
          return new
        }
      }
      .bind(to: wishTextView.rx.text)
      .disposed(by: disposeBag)
    
    // 텍스트뷰 반응 -> 글자수 레이블 반응
    wishTextView.rx.text
      .orEmpty
      .bind(onNext: { [unowned self] text in
        self.letterNumLabel.text = "\(text.count)/100pt"
        let attributedString = NSMutableAttributedString(string: "\(text.count)/100pt")
        attributedString.addAttribute(.foregroundColor, value: UIColor.idorm_blue, range: ("\(text.count)/100pt" as NSString).range(of: "\(text.count)"))
        self.letterNumLabel.attributedText = attributedString
        //        self.onChangedTextSubject.onNext((text, self.type))
      })
      .disposed(by: disposeBag)
    
    // 스킵 버튼 이벤트
    floatyBottomView.skipButton.rx.tap
      .map { [unowned self] in self.floatyBottomView.floatyBottomViewType }
      .bind(to: viewModel.input.didTapSkipButton)
      .disposed(by: disposeBag)
    
    // 완료 버튼 이벤트
    floatyBottomView.confirmButton.rx.tap
      .bind(to: viewModel.input.didTapConfirmButton)
      .disposed(by: disposeBag)
    
    // 1기숙사 버튼 클릭
    dorm1Button.rx.tap
      .map { [weak self] _ -> Dormitory in
        self?.toggleDromButton(.no1)
        return Dormitory.no1
      }
      .bind(to: viewModel.input.isSelectedDormButton)
      .disposed(by: disposeBag)
    
    // 2기숙사 버튼 클릭
    dorm2Button.rx.tap
      .map { [weak self] _ -> Dormitory in
        self?.toggleDromButton(.no2)
        return Dormitory.no2
      }
      .bind(to: viewModel.input.isSelectedDormButton)
      .disposed(by: disposeBag)
    
    // 3기숙사 버튼 클릭
    dorm3Button.rx.tap
      .map { [weak self] _ -> Dormitory in
        self?.toggleDromButton(.no3)
        return Dormitory.no3
      }
      .bind(to: viewModel.input.isSelectedDormButton)
      .disposed(by: disposeBag)
    
    // 남성 버튼 클릭
    maleButton.rx.tap
      .map { [weak self] _ -> Gender in
        self?.toggleGenderButton(.male)
        return Gender.male
      }
      .bind(to: viewModel.input.isSelectedGenderButton)
      .disposed(by: disposeBag)
    
    // 여성 버튼 클릭
    femaleButton.rx.tap
      .map { [weak self] _ -> Gender in
        self?.toggleGenderButton(.female)
        return Gender.female
      }
      .bind(to: viewModel.input.isSelectedGenderButton)
      .disposed(by: disposeBag)
    
    // 16주 버튼 클릭
    period16Button.rx.tap
      .map { [weak self] _ -> JoinPeriod in
        self?.togglePeriodButton(.period_16)
        return JoinPeriod.period_16
      }
      .bind(to: viewModel.input.isSelectedPeriodButton)
      .disposed(by: disposeBag)
    
    // 24주 버튼 클릭
    period24Button.rx.tap
      .map { [weak self] _ -> JoinPeriod in
        self?.togglePeriodButton(.period_24)
        return JoinPeriod.period_24
      }
      .bind(to: viewModel.input.isSelectedPeriodButton)
      .disposed(by: disposeBag)
    
    // 코골이 버튼 클릭
    snoreButton.rx.tap
      .map { [weak self] _ -> Habit in
        self?.snoreButton.isSelected.toggle()
        return Habit.snoring
      }
      .bind(to: viewModel.input.isSelectedHabitButton)
      .disposed(by: disposeBag)
    
    // 이갈이 버튼 클릭
    grindingButton.rx.tap
      .map { [weak self] _ -> Habit in
        self?.grindingButton.isSelected.toggle()
        return Habit.grinding
      }
      .bind(to: viewModel.input.isSelectedHabitButton)
      .disposed(by: disposeBag)
    
    // 흡연 버튼 클릭
    smokingButton.rx.tap
      .map { [weak self] _ -> Habit in
        self?.smokingButton.isSelected.toggle()
        return Habit.smoking
      }
      .bind(to: viewModel.input.isSelectedHabitButton)
      .disposed(by: disposeBag)
    
    // 실내음식섭취 버튼 클릭
    allowedFoodButton.rx.tap
      .map { [weak self] _ -> Habit in
        self?.allowedFoodButton.isSelected.toggle()
        return Habit.allowedFood
      }
      .bind(to: viewModel.input.isSelectedHabitButton)
      .disposed(by: disposeBag)
    
    // 이어폰착용안함 버튼 클릭
    allowedEarphoneButton.rx.tap
      .map { [weak self] _ -> Habit in
        self?.allowedEarphoneButton.isSelected.toggle()
        return Habit.allowedEarphone
      }
      .bind(to: viewModel.input.isSelectedHabitButton)
      .disposed(by: disposeBag)
    
    // 나이 텍스트 반응 전달
    ageTextField.rx.text
      .orEmpty
      .map { (OnboardingQueryList.age, $0) }
      .bind(to: viewModel.input.onChangedQueryText)
      .disposed(by: disposeBag)
    
    // 기상 시간 텍스트 반응
    wakeUpTextField.textField.rx.text
      .orEmpty
      .map { (OnboardingQueryList.wakeUp, $0) }
      .bind(to: viewModel.input.onChangedQueryText)
      .disposed(by: disposeBag)
    
    // 정리 정돈 텍스트 반응
    cleanUpTextField.textField.rx.text
      .orEmpty
      .map { (OnboardingQueryList.cleanUp, $0) }
      .bind(to: viewModel.input.onChangedQueryText)
      .disposed(by: disposeBag)
    
    // 샤워 텍스트 반응
    showerTextField.textField.rx.text
      .orEmpty
      .map { (OnboardingQueryList.shower, $0) }
      .bind(to: viewModel.input.onChangedQueryText)
      .disposed(by: disposeBag)
    
    // mbti 텍스트 반응
    mbtiTextField.textField.rx.text
      .orEmpty
      .map { (OnboardingQueryList.mbti, $0) }
      .bind(to: viewModel.input.onChangedQueryText)
      .disposed(by: disposeBag)
    
    // 오픈채팅 텍스트 반응
    chatTextField.textField.rx.text
      .orEmpty
      .map { (OnboardingQueryList.chatLink, $0) }
      .bind(to: viewModel.input.onChangedQueryText)
      .disposed(by: disposeBag)
    
    // 하고 싶은 말 텍스트 반응
    wishTextView.rx.text
      .orEmpty
      .map { (OnboardingQueryList.wishText, $0) }
      .bind(to: viewModel.input.onChangedQueryText)
      .disposed(by: disposeBag)
    
    // MARK: - Output
    
    // 완료 버튼 활성&비활성
    viewModel.output.isEnableConfirmButton
      .bind(onNext: { [unowned self] isEnable in
        if isEnable {
          self.floatyBottomView.confirmButton.isEnabled = true
        } else {
          self.floatyBottomView.confirmButton.isEnabled = false
        }
      })
      .disposed(by: disposeBag)
    
    // 입력 초기화
    viewModel.output.resetData
      .bind(onNext: { [weak self] in
        self?.resetData()
      })
      .disposed(by: disposeBag)
    
    // 메인페이지로 넘어가기
    viewModel.output.showTabBarVC
      .bind(onNext: { [weak self] in
        let tabBarVC = TabBarController()
        tabBarVC.modalPresentationStyle = .fullScreen
        self?.present(tabBarVC, animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  
  private func resetData() {
    [dorm1Button, dorm2Button, dorm3Button,
     maleButton, femaleButton,
     period16Button, period24Button,
     snoreButton, grindingButton, smokingButton, allowedFoodButton, allowedEarphoneButton]
      .forEach { $0.isSelected = false }
    
    [wakeUpTextField, cleanUpTextField, showerTextField, mbtiTextField, chatTextField]
      .forEach {
        $0.textField.text = ""
        $0.checkmarkButton.isHidden = true
      }
    
    ageTextField.text = ""
    ageTextField.labels.forEach {
      $0.text = ""
    }
    wishTextView.text = ""
    floatyBottomView.confirmButton.isEnabled = false
  }
  
  @objc private func didTapScrollView() {
    self.view.endEditing(true)
  }
}

// MARK: - Button Toggle

extension OnboardingViewController {
  private func toggleDromButton(_ dorm: Dormitory) {
    switch dorm {
    case .no1:
      dorm1Button.isSelected = true
      dorm2Button.isSelected = false
      dorm3Button.isSelected = false
    case .no2:
      dorm1Button.isSelected = false
      dorm2Button.isSelected = true
      dorm3Button.isSelected = false
    case .no3:
      dorm1Button.isSelected = false
      dorm2Button.isSelected = false
      dorm3Button.isSelected = true
    }
  }
  
  private func toggleGenderButton(_ gender: Gender) {
    switch gender {
    case .female:
      femaleButton.isSelected = true
      maleButton.isSelected = false
    case .male:
      femaleButton.isSelected = false
      maleButton.isSelected = true
    }
  }
  
  private func togglePeriodButton(_ period: JoinPeriod) {
    switch period {
    case .period_16:
      period16Button.isSelected = true
      period24Button.isSelected = false
    case .period_24:
      period16Button.isSelected = false
      period24Button.isSelected = true
    }
  }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct OnboardingViewController_PreView: PreviewProvider {
  static var previews: some View {
    OnboardingViewController(.mainPage_FirstTime).toPreview()
  }
}
#endif
