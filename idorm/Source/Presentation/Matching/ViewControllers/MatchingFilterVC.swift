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
  
  private let dormLabel = MatchingUtilities.titleLabel(text: "기숙사")
  private let dorm1Button = MatchingUtilities.basicButton(title: "1 기숙사")
  private let dorm2Button = MatchingUtilities.basicButton(title: "2 기숙사")
  private let dorm3Button = MatchingUtilities.basicButton(title: "3 기숙사")
  private let dormLine = MatchingUtilities.separatorLine()
  private var dormStack: UIStackView!
  
  private let periodLabel = MatchingUtilities.titleLabel(text: "입사 기간")
  private let period16Button = MatchingUtilities.basicButton(title: "16 주")
  private let period24Button = MatchingUtilities.basicButton(title: "24 주")
  private let periodLine = MatchingUtilities.separatorLine()
  private var periodStack: UIStackView!
  
  private let habitDescriptionLabel = MatchingUtilities.descriptionLabel("선택하신 요소를 가진 룸메이트는 나와 매칭되지 않아요.")
  private let habitLabel = MatchingUtilities.titleLabel(text: "불호 요소")
  private let snoreButton = MatchingUtilities.basicButton(title: "코골이")
  private let grindingButton = MatchingUtilities.basicButton(title: "이갈이")
  private let smokingButton = MatchingUtilities.basicButton(title: "흡연")
  private let allowedFoodButton = MatchingUtilities.basicButton(title: "실내 음식 섭취 함")
  private let allowedEarphoneButton = MatchingUtilities.basicButton(title: "이어폰 착용 안함")
  private let habitLine = MatchingUtilities.separatorLine()
  private var habitStack1: UIStackView!
  private var habitStack2: UIStackView!
  
  private let ageLabel = MatchingUtilities.titleLabel(text: "나이")
  private let ageDescriptionLabel = MatchingUtilities.descriptionLabel("선택하신 연령대의 룸메이트만 나와 매칭돼요.")
  private let slider = MatchingUtilities.slider()
  private let filterDriver = FilterDriver()
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    setupStackView()
    super.viewDidLoad()
    
    reactor?.filterDriver = filterDriver
    reactor?.action.onNext(.viewDidLoad)
    
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
      .map { $0.0.snoreButton.isSelected }
      .map { MatchingFilterViewReactor.Action.didTapHabitButton(.snoring, $0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    grindingButton.rx.tap
      .withUnretained(self)
      .do { $0.0.grindingButton.isSelected.toggle() }
      .map { $0.0.grindingButton.isSelected }
      .map { MatchingFilterViewReactor.Action.didTapHabitButton(.grinding, $0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    smokingButton.rx.tap
      .withUnretained(self)
      .do { $0.0.smokingButton.isSelected.toggle() }
      .map { $0.0.smokingButton.isSelected }
      .map { MatchingFilterViewReactor.Action.didTapHabitButton(.smoking, $0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    allowedFoodButton.rx.tap
      .withUnretained(self)
      .do { $0.0.allowedFoodButton.isSelected.toggle() }
      .map { $0.0.allowedFoodButton.isSelected }
      .map { MatchingFilterViewReactor.Action.didTapHabitButton(.allowedFood, $0) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)

    allowedEarphoneButton.rx.tap
      .withUnretained(self)
      .do { $0.0.allowedEarphoneButton.isSelected.toggle() }
      .map { $0.0.allowedEarphoneButton.isSelected }
      .map { MatchingFilterViewReactor.Action.didTapHabitButton(.allowedEarphone, $0) }
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

    filterDriver.isAllowed
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

  private func updateFilteredUI(_ filter: MatchingDTO.Filter) {
    toggleDromButton(filter.dormNum)
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
