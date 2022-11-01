import UIKit

import SnapKit
import Then
import RxSwift
import RxCocoa

enum OnboardingVCType {
  /// 회원가입 후 최초 온보딩 접근
  case firstTime
  /// 메인페이지 최초 접속 후 온보딩 접근
  case firstTime_2
  /// 온보딩 수정
  case update
}

final class OnboardingViewController: BaseViewController {
  
  // MARK: - Properties
  
  private lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
    $0.estimatedRowHeight = 100
    $0.rowHeight = UITableView.automaticDimension
    $0.estimatedSectionHeaderHeight = 100
    $0.sectionHeaderHeight = UITableView.automaticDimension
    $0.backgroundColor = .white
    $0.separatorStyle = .none
    $0.allowsSelection = false
    $0.register(
      OnboardingTableViewCell.self,
      forCellReuseIdentifier: OnboardingTableViewCell.identifier
    )
    $0.register(
      OnboardingTableHeaderView.self,
      forHeaderFooterViewReuseIdentifier: OnboardingTableHeaderView.identifier
    )
    $0.addGestureRecognizer(tableViewTapGesture)
    $0.delegate = self
    $0.dataSource = self
  }
  
  private lazy var tableViewTapGesture = UITapGestureRecognizer().then {
    $0.addTarget(self, action: #selector(hideKeyboard))
    $0.cancelsTouchesInView = true
  }
  
  private lazy var floatyBottomView = OnboardingFloatyBottomView().then {
    switch type {
    case .update:
      $0.configureUI(type: .update)
    case .firstTime:
      $0.configureUI(type: .normal)
    case .firstTime_2:
      $0.configureUI(type: .update)
    }
  }
  
  private let type: OnboardingVCType
  private var header: OnboardingTableHeaderView!
  private let viewModel = OnboardingViewModel()
  
  // MARK: - Init
  
  init(type: OnboardingVCType) {
    self.type = type
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Selectors
  
  @objc private func hideKeyboard() {
    tableView.endEditing(true)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    view.backgroundColor = .white
    navigationController?.navigationBar.tintColor = .black
    navigationController?.navigationBar.isHidden = false
    tabBarController?.tabBar.isHidden = true
    
    switch type {
    case .firstTime:
      navigationItem.title = "내 정보 입력"
    case .firstTime_2:
      navigationItem.title = "매칭 이미지 관리"
    case .update:
      navigationItem.title = "매칭 이미지 관리"
    }
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [tableView, floatyBottomView]
      .forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    tableView.snp.makeConstraints { make in
      make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
      make.bottom.equalTo(floatyBottomView.snp.top)
    }
    
    floatyBottomView.snp.makeConstraints { make in
      make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
      make.leading.trailing.equalToSuperview()
      make.height.equalTo(76)
    }
  }

  override func bind() {
    super.bind()
    
    // ---------------------------------
    // ---------------INPUT-------------
    // ---------------------------------
    
    // 완료 버튼 이벤트
    floatyBottomView.confirmButton.rx.tap
      .bind(to: viewModel.input.didTapConfirmButton)
      .disposed(by: disposeBag)
    
    // 건너뛰기 버튼 이벤트
    floatyBottomView.skipButton.rx.tap
      .bind(to: viewModel.input.didTapSkipButton)
      .disposed(by: disposeBag)

    // ---------------------------------
    // --------------OUTPUT-------------
    // ---------------------------------
    
    // 완료 버튼 활성화/비활성화
    viewModel.output.enableConfirmButton
      .subscribe(onNext: { [weak self] isEnabled in
        if isEnabled {
          self?.floatyBottomView.confirmButton.isUserInteractionEnabled = true
          self?.floatyBottomView.confirmButton.configuration?.baseBackgroundColor = .idorm_blue
        } else {
          self?.floatyBottomView.confirmButton.isUserInteractionEnabled = false
          self?.floatyBottomView.confirmButton.configuration?.baseBackgroundColor = .idorm_gray_300
        }
      })
      .disposed(by: disposeBag)
    
    // 완료 버튼 클릭시 온보딩 디테일 화면으로 이동
    viewModel.output.showOnboardingDetailVC
      .bind(onNext: { [weak self] myinfo in
        let vc = OnboardingDetailViewController(matchingInfo: myinfo)
        self?.navigationController?.pushViewController(vc, animated: true)
      })
      .disposed(by: disposeBag)
    
    switch type {
    case .update, .firstTime_2:
      break
      
      
    case .firstTime:
      
      // 정보 입력 건너 뛰고 메인 화면으로 이동
      viewModel.output.showTabBarVC
        .bind(onNext: { [weak self] in
          let tabBarVC = TabBarController()
          tabBarVC.modalPresentationStyle = .fullScreen
          self?.present(tabBarVC, animated: true)
        })
        .disposed(by: disposeBag)
    }
  }
  
  private func bindHeader() {
    
    header.onChangedDorm1Button
      .bind(to: viewModel.input.dorm1ButtonTapped)
      .disposed(by: disposeBag)
    
    header.onChangedDorm2Button
      .bind(to: viewModel.input.dorm2ButtonTapped)
      .disposed(by: disposeBag)
    
    header.onChangedDorm3Button
      .bind(to: viewModel.input.dorm3ButtonTapped)
      .disposed(by: disposeBag)
    
    header.onChangedMaleButton
      .bind(to: viewModel.input.maleButtonTapped)
      .disposed(by: disposeBag)
    
    header.onChangedFemaleButton
      .bind(to: viewModel.input.femaleButtonTapped)
      .disposed(by: disposeBag)
    
    header.onChangedPeriod16Button
      .bind(to: viewModel.input.period16ButtonTapped)
      .disposed(by: disposeBag)
    
    header.onChangedPeriod24Button
      .bind(to: viewModel.input.period24ButtonTapped)
      .disposed(by: disposeBag)
    
    header.onChangedSnoringButton
      .bind(to: viewModel.input.snoringButtonTapped)
      .disposed(by: disposeBag)
    
    header.onChangedGrindingButton
      .bind(to: viewModel.input.grindingButtonTapped)
      .disposed(by: disposeBag)
    
    header.onChangedSmokingButton
      .bind(to: viewModel.input.smokingButtonTapped)
      .disposed(by: disposeBag)
    
    header.onChangedAllowedFoodButton
      .bind(to: viewModel.input.allowedFoodButtonTapped)
      .disposed(by: disposeBag)
    
    header.onChangedAllowedEarphoneButton
      .bind(to: viewModel.input.allowedEarphoneButtonTapped)
      .disposed(by: disposeBag)
    
    header.onChangedAgeTextField
      .bind(to: viewModel.input.ageTextFieldChanged)
      .disposed(by: disposeBag)
  }
}

// MARK: - TableView Setup

extension OnboardingViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: OnboardingTableViewCell.identifier,
      for: indexPath
    ) as? OnboardingTableViewCell else {
      return UITableViewCell()
    }
    let question = viewModel.getQuestionText(index: indexPath.row)
    let onboardingListType = OnboardingListType.allCases[indexPath.row]
    cell.configureUI(type: onboardingListType, question: question)
    
    cell.onChangedTextSubject
      .subscribe(onNext: { [weak self] text, type in
        guard let self = self else { return }
        switch type {
        case .wakeup:
          self.viewModel.input.wakeUpTimeTextFieldChanged
            .accept(text)
        case .cleanup:
          self.viewModel.input.cleanUpTimeTextFieldChanged
            .accept(text)
        case .shower:
          self.viewModel.input.showerTimeTextFieldChanged
            .accept(text)
        case .mbti:
          self.viewModel.input.mbtiTextFieldChanged
            .accept(text)
        case .chatLink:
          self.viewModel.input.chatLinkTextFieldChanged
            .accept(text)
        case .wishText:
          self.viewModel.input.wishTextTextFieldChanged
            .accept(text)
        }
      })
      .disposed(by: disposeBag)
    
    return cell
  }
  
  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
  ) -> Int {
    return viewModel.numberOfRowsInSection
  }
  
  func tableView(
    _ tableView: UITableView,
    viewForHeaderInSection section: Int
  ) -> UIView? {
    guard let header = tableView.dequeueReusableHeaderFooterView(
      withIdentifier: OnboardingTableHeaderView.identifier
    ) as? OnboardingTableHeaderView else {
      return UIView()
    }
    header.configureUI(type: .normal)
    
    if self.header == nil {
      self.header = header
      bindHeader()
    }
    
    return header
  }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct OnboardingVCPreView: PreviewProvider {
  static var previews: some View {
    OnboardingViewController(type: .firstTime_2).toPreview()
  }
}
#endif
