//
//  MatchingFilterViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/19.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import RangeSeekSlider

final class MatchingFilterViewController: BaseViewController, View {
  
  // MARK: - Properties
  
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  private let floatyBottomView = FloatyBottomView(.filter)
  
  private let dormLabel = UIFactory.label(
    "기숙사",
    textColor: .black,
    font: .iDormFont(.medium, size: 16)
  )
  
  private let periodLabel = UIFactory.label(
    "입사 기간",
    textColor: .black,
    font: .iDormFont(.medium, size: 16)
  )
  
  private let habitLabel = UIFactory.label(
    "불호요소",
    textColor: .black,
    font: .iDormFont(.medium, size: 16)
  )
  
  private let ageLabel = UIFactory.label(
    "나이",
    textColor: .black,
    font: .iDormFont(.medium, size: 16)
  )

  private let habitDescriptionLabel = UIFactory.label(
    "선택하신 요소를 가진 룸메이트는 나와 매칭되지 않아요.",
    textColor: .idorm_gray_300,
    font: .iDormFont(.medium, size: 12)
  )
  
  private let ageDescriptionLabel = UIFactory.label(
    "선택하신 연령대의 룸메이트만 나와 매칭돼요.",
    textColor: .idorm_gray_300,
    font: .iDormFont(.medium, size: 12)
  )
  
  private let slider: RangeSeekSlider = {
    let slider = RangeSeekSlider()
    slider.backgroundColor = .white
    slider.colorBetweenHandles = .idorm_blue
    slider.tintColor = .idorm_gray_100
    slider.labelPadding = 6
    slider.minLabelColor = .black
    slider.maxLabelColor = .black
    slider.minLabelFont = .init(name: IdormFont_deprecated.medium.rawValue, size: 12)!
    slider.maxLabelFont = .init(name: IdormFont_deprecated.medium.rawValue, size: 12)!
    slider.minValue = 20
    slider.maxValue = 40
    slider.selectedMaxValue = 30
    slider.selectedMinValue = 20
    slider.lineHeight = 11
    slider.handleImage = UIImage(named: "circle_blue_large")
    slider.minDistance = 1
    slider.enableStep = true
    slider.selectedHandleDiameterMultiplier = 1.0
    
    return slider
  }()

  private let dorm1Button = OnboardingButton("1 기숙사")
  private let dorm2Button = OnboardingButton("2 기숙사")
  private let dorm3Button = OnboardingButton("3 기숙사")
  private let period16Button = OnboardingButton("짧은 기간")
  private let period24Button = OnboardingButton("긴 기간")
  private let snoreButton = OnboardingButton("코골이")
  private let grindingButton = OnboardingButton("이갈이")
  private let smokingButton = OnboardingButton("흡연")
  private let allowedFoodButton = OnboardingButton("실내 음식 섭취 함")
  private let allowedEarphoneButton = OnboardingButton("이어폰 착용 안함")

  private let dormLine = UIFactory.view(.idorm_gray_100)
  private let periodLine = UIFactory.view(.idorm_gray_100)
  private let habitLine = UIFactory.view(.idorm_gray_100)
  
  private var dormStack: UIStackView!
  private var periodStack: UIStackView!
  private var habitStack1: UIStackView!
  private var habitStack2: UIStackView!
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    setupStackView()
    super.viewDidLoad()
    
    if FilterStorage.shared.hasFilter {
      updateFilteredUI(FilterStorage.shared.filter)
    }
  }

  // MARK: - Bind
  
  func bind(reactor: MatchingFilterViewReactor) {
    
    // MARK: - Action

    // 선택초기화 버튼
    floatyBottomView.leftButton.rx.tap
      .map { MatchingFilterViewReactor.Action.didTapResetButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    // 필터링완료 버튼
    floatyBottomView.rightButton.rx.tap
      .map { MatchingFilterViewReactor.Action.didTapConfirmButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    // 기숙사버튼
    dorm1Button.rx.tap
      .withUnretained(self)
      .do { $0.0.toggleDromButton(.no1) }
      .map { _ in MatchingFilterViewReactor.Action.didTapDormButton(.no1) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    dorm2Button.rx.tap
      .withUnretained(self)
      .do { $0.0.toggleDromButton(.no2) }
      .map { _ in MatchingFilterViewReactor.Action.didTapDormButton(.no2) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    dorm3Button.rx.tap
      .withUnretained(self)
      .do { $0.0.toggleDromButton(.no3) }
      .map { _ in MatchingFilterViewReactor.Action.didTapDormButton(.no3) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    // 입사기간 버튼
    period16Button.rx.tap
      .withUnretained(self)
      .do { $0.0.togglePeriodButton(.period_16) }
      .map { _ in MatchingFilterViewReactor.Action.didTapJoinPeriodButton(.period_16) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    period24Button.rx.tap
      .withUnretained(self)
      .do { $0.0.togglePeriodButton(.period_24) }
      .map { _ in MatchingFilterViewReactor.Action.didTapJoinPeriodButton(.period_24) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    // 불호요소 버튼
    snoreButton.rx.tap
      .withUnretained(self)
      .do { $0.0.snoreButton.isSelected.toggle() }
      .map { _ in MatchingFilterViewReactor.Action.didTapHabitButton(.snoring) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    grindingButton.rx.tap
      .withUnretained(self)
      .do { $0.0.grindingButton.isSelected.toggle() }
      .map { _ in MatchingFilterViewReactor.Action.didTapHabitButton(.grinding) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    smokingButton.rx.tap
      .withUnretained(self)
      .do { $0.0.smokingButton.isSelected.toggle() }
      .map { _ in MatchingFilterViewReactor.Action.didTapHabitButton(.smoking) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    allowedFoodButton.rx.tap
      .withUnretained(self)
      .do { $0.0.allowedFoodButton.isSelected.toggle() }
      .map { _ in MatchingFilterViewReactor.Action.didTapHabitButton(.allowedFood) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    allowedEarphoneButton.rx.tap
      .withUnretained(self)
      .do { $0.0.allowedEarphoneButton.isSelected.toggle() }
      .map { _ in MatchingFilterViewReactor.Action.didTapHabitButton(.allowedEarphone) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // MARK: - State
    
    reactor.state
      .map { $0.popVC }
      .filter { $0 }
      .map { _ in Void() }
      .withUnretained(self)
      .bind { $0.0.navigationController?.popViewController(animated: true) }
      .disposed(by: disposeBag)

    FilterDriver.shared.isAllowed
      .bind(to: floatyBottomView.rightButton.rx.isEnabled)
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup

  override func setupStyles() {
    super.setupStyles()
    
    navigationController?.setNavigationBarHidden(false, animated: true)
    contentView.backgroundColor = .white
    view.backgroundColor = .white
    navigationItem.title = "필터"
    slider.delegate = self
  }

  override func setupLayouts() {
    super.setupLayouts()

    view.addSubview(scrollView)
    scrollView.addSubview(contentView)

    [floatyBottomView, scrollView]
      .forEach { view.addSubview($0) }

    [dormLabel, dormStack, dormLine, periodLabel, periodStack, periodLine, habitLabel, habitDescriptionLabel, habitStack1, habitStack2, habitLine, ageLabel, ageDescriptionLabel, slider]
      .forEach { contentView.addSubview($0) }
  }

  override func setupConstraints() {
    super.setupConstraints()

    scrollView.snp.makeConstraints { make in
      make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
      make.bottom.equalTo(floatyBottomView.snp.top)
    }

    floatyBottomView.snp.makeConstraints { make in
      make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
      make.height.equalTo(84)
    }

    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalTo(view.frame.width)
    }

    dormLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalToSuperview().inset(16)
    }

    dormStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(dormLabel.snp.bottom).offset(10)
    }

    dormLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(dormStack.snp.bottom).offset(16)
      make.height.equalTo(1)
    }

    periodLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(dormLine.snp.bottom).offset(16)
    }

    periodStack.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(periodLabel.snp.bottom).offset(10)
    }

    periodLine.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(periodStack.snp.bottom).offset(16)
      make.height.equalTo(1)
    }

    habitLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(periodLine.snp.bottom).offset(16)
    }

    habitDescriptionLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(habitLabel.snp.bottom)
    }

    habitStack1.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(habitDescriptionLabel.snp.bottom).offset(10)
    }

    habitStack2.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(habitStack1.snp.bottom).offset(12)
    }

    habitLine.snp.makeConstraints { make in
      make.top.equalTo(habitStack2.snp.bottom).offset(16)
      make.leading.trailing.equalToSuperview().inset(24)
      make.height.equalTo(1)
    }

    ageLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(habitLine.snp.bottom).offset(16)
    }

    ageDescriptionLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.top.equalTo(ageLabel.snp.bottom)
    }

    slider.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.top.equalTo(ageDescriptionLabel.snp.bottom)
      make.bottom.equalToSuperview().inset(32)
    }
  }

  private func setupStackView() {
    let dormStack = UIStackView(arrangedSubviews: [ dorm1Button, dorm2Button, dorm3Button ])
    dormStack.spacing = 12
    self.dormStack = dormStack

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

  // MARK: - Helpers
  
  private func updateFilteredUI(_ filter: MatchingRequestModel.Filter) {
    print(filter)
    toggleDromButton(filter.dormCategory)
    togglePeriodButton(filter.joinPeriod)
    snoreButton.isSelected = filter.isSnoring
    grindingButton.isSelected = filter.isGrinding
    smokingButton.isSelected = filter.isSmoking
    allowedFoodButton.isSelected = filter.isAllowedFood
    allowedEarphoneButton.isSelected = filter.isWearEarphones
    slider.selectedMinValue = CGFloat(filter.minAge)
    slider.selectedMaxValue = CGFloat(filter.maxAge)
    floatyBottomView.rightButton.isEnabled = true
  }
  
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

// MARK: - Slider Delegate

extension MatchingFilterViewController: RangeSeekSliderDelegate {
  func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
    guard let reactor = reactor else { return }
    let minValue = Int(round(minValue))
    let maxValue = Int(round(maxValue))
    
    Observable.just((minValue, maxValue))
      .map { MatchingFilterViewReactor.Action.didChangeSlider(minValue: $0.0, maxValue: $0.1) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
}
