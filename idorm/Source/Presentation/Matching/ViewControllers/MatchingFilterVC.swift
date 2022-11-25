import UIKit

import SnapKit
import RxSwift
import RxCocoa
import RangeSeekSlider

final class MatchingFilterViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  private let floatyBottomView = FloatyBottomView(.filter)
  let viewModel = MatchingFilterViewModel()
  private let matchingFilterShared = MatchingFilterStorage.shared
  
  // MARK: - Dorm
  private let dormLabel = MatchingUtilities.titleLabel(text: "기숙사")
  private let dorm1Button = MatchingUtilities.basicButton(title: "1 기숙사")
  private let dorm2Button = MatchingUtilities.basicButton(title: "2 기숙사")
  private let dorm3Button = MatchingUtilities.basicButton(title: "3 기숙사")
  private let dormLine = MatchingUtilities.separatorLine()
  private var dormStack: UIStackView!
  
  // MARK: - Period
  private let periodLabel = MatchingUtilities.titleLabel(text: "입사 기간")
  private let period16Button = MatchingUtilities.basicButton(title: "16 주")
  private let period24Button = MatchingUtilities.basicButton(title: "24 주")
  private let periodLine = MatchingUtilities.separatorLine()
  private var periodStack: UIStackView!
  
  // MARK: - Habit
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
  
  // MARK: - Age
  private let ageLabel = MatchingUtilities.titleLabel(text: "나이")
  private let ageDescriptionLabel = MatchingUtilities.descriptionLabel("선택하신 연령대의 룸메이트만 나와 매칭돼요.")
  private let slider = MatchingUtilities.slider()
  
  // MARK: - LifeCycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = false
    floatyBottomView.rightButton.isEnabled = false
    
    // MARK: - 현재 필터 정보 확인 후 UI 업데이트
    if matchingFilterShared.hasFilter {
      guard let filter = matchingFilterShared.matchingFilterObserver.value else { fatalError() }
      updateFilteredUI(filter)
    }
  }
  
  override func viewDidLoad() {
    setupStackView()
    super.viewDidLoad()
  }

  // MARK: - Bind
  
  override func bind() {
    
    // MARK: - Input
    
    // 선택 초기화 버튼 클릭
    floatyBottomView.leftButton.rx.tap
      .bind(to: viewModel.input.skipButtonTapped)
      .disposed(by: disposeBag)
    
    // 필터링 완료 버튼 클릭
    floatyBottomView.rightButton.rx.tap
      .bind(to: viewModel.input.confirmButtonTapped)
      .disposed(by: disposeBag)
    
    // 1 기숙사 버튼 클릭
    dorm1Button.rx.tap
      .map { [unowned self] _ -> Dormitory in
        self.toggleDromButton(.no1)
        return Dormitory.no1
      }
      .bind(to: viewModel.input.isSelectedDormButton)
      .disposed(by: disposeBag)
    
    // 2 기숙사 버튼 클릭
    dorm2Button.rx.tap
      .map { [unowned self] _ -> Dormitory in
        self.toggleDromButton(.no2)
        return Dormitory.no2
      }
      .bind(to: viewModel.input.isSelectedDormButton)
      .disposed(by: disposeBag)

    // 3 기숙사 버튼 클릭
    dorm3Button.rx.tap
      .map { [unowned self] _ -> Dormitory in
        self.toggleDromButton(.no3)
        return Dormitory.no3
      }
      .bind(to: viewModel.input.isSelectedDormButton)
      .disposed(by: disposeBag)

    // 16 주 버튼 클릭
    period16Button.rx.tap
      .map { [unowned self] _ -> JoinPeriod in
        self.togglePeriodButton(.period_16)
        return JoinPeriod.period_16
      }
      .bind(to: viewModel.input.isSelectedPeriodButton)
      .disposed(by: disposeBag)
    
    // 24 주 버튼 클릭
    period24Button.rx.tap
      .map { [unowned self] _ -> JoinPeriod in
        self.togglePeriodButton(.period_24)
        return JoinPeriod.period_24
      }
      .bind(to: viewModel.input.isSelectedPeriodButton)
      .disposed(by: disposeBag)
    
    // 코골이 버튼 클릭
    snoreButton.rx.tap
      .map { [unowned self] _ -> Habit in
        self.snoreButton.isSelected.toggle()
        return Habit.snoring
      }
      .bind(to: viewModel.input.isSelectedHabitButton)
      .disposed(by: disposeBag)
    
    // 이갈이 버튼 클릭
    grindingButton.rx.tap
      .map { [unowned self] _ -> Habit in
        self.grindingButton.isSelected.toggle()
        return Habit.grinding
      }
      .bind(to: viewModel.input.isSelectedHabitButton)
      .disposed(by: disposeBag)

    // 흡연 버튼 클릭
    smokingButton.rx.tap
      .map { [unowned self] _ -> Habit in
        self.smokingButton.isSelected.toggle()
        return Habit.smoking
      }
      .bind(to: viewModel.input.isSelectedHabitButton)
      .disposed(by: disposeBag)

    // 실내 음식 섭취 버튼 클릭
    allowedFoodButton.rx.tap
      .map { [unowned self] _ -> Habit in
        self.allowedFoodButton.isSelected.toggle()
        return Habit.allowedFood
      }
      .bind(to: viewModel.input.isSelectedHabitButton)
      .disposed(by: disposeBag)

    // 이어폰 착용 버튼 클릭
    allowedEarphoneButton.rx.tap
      .map { [unowned self] _ -> Habit in
        self.allowedEarphoneButton.isSelected.toggle()
        return Habit.allowedEarphone
      }
      .bind(to: viewModel.input.isSelectedHabitButton)
      .disposed(by: disposeBag)
    
    // MARK: - Output
    
    // 필터링 완료 버튼 활성&비활성화
    viewModel.output.isEnableConfirmButton
      .bind(onNext: { [unowned self] isEnable in
        if isEnable {
          self.floatyBottomView.rightButton.isEnabled = true
        } else {
          self.floatyBottomView.rightButton.isEnabled = false
        }
      })
      .disposed(by: disposeBag)
    
    // 뒤로가기
    viewModel.output.popVC
      .bind(onNext: { [unowned self] in
        self.navigationController?.popViewController(animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
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
  
  private func updateFilteredUI(_ filter: MatchingFilter) {
    toggleDromButton(filter.dormNum)
    togglePeriodButton(filter.period)
    snoreButton.isSelected = filter.isSnoring
    grindingButton.isSelected = filter.isGrinding
    smokingButton.isSelected = filter.isSmoking
    allowedFoodButton.isSelected = filter.isAllowedFood
    allowedEarphoneButton.isSelected = filter.isWearEarphones
    slider.selectedMinValue = CGFloat(filter.minAge)
    slider.selectedMaxValue = CGFloat(filter.maxAge)
    floatyBottomView.rightButton.isEnabled = true
  }
}

// MARK: - Button Toggle

extension MatchingFilterViewController {
  
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
    // 슬라이더 반응 이벤트 전달
    viewModel.input.onChangedAgeSlider.onNext((Int(minValue), Int(maxValue)))
  }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct MatchingFilterVC_PreView: PreviewProvider {
  static var previews: some View {
    MatchingFilterViewController().toPreview()
  }
}
#endif
