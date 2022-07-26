//
//  OnboardingVIewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/24.
//

import SnapKit
import UIKit
import RxSwift
import RxCocoa

class OnboardingViewController: UIViewController {
  // MARK: - Properties
  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.estimatedRowHeight = 100
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedSectionHeaderHeight = 100
    tableView.sectionHeaderHeight = UITableView.automaticDimension
    tableView.backgroundColor = .white
    tableView.separatorStyle = .none
    tableView.allowsSelection = false
    tableView.register(OnboardingTableViewCell.self, forCellReuseIdentifier: OnboardingTableViewCell.identifier)
    tableView.register(OnboardingTableHeaderView.self, forHeaderFooterViewReuseIdentifier: OnboardingTableHeaderView.identifier)
    tableView.delegate = self
    tableView.dataSource = self
    
    return tableView
  }()
  
  lazy var tableViewTapGesture: UITapGestureRecognizer = {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
    tapGesture.cancelsTouchesInView = true
    
    return tapGesture
  }()

  let floatyBottomView = OnboardingFloatyBottomView()
  
  let viewModel = OnboardingViewModel()
  let disposeBag = DisposeBag()
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }
  
  // MARK: - Selectors
  @objc private func didTapSkipButton() {
    print("Skip!")
  }
  
  @objc private func didTapConfirmButton() {
    print("Confirm!")
  }
  
  @objc private func hideKeyboard() {
    tableView.endEditing(true)
  }
  
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .white
    navigationItem.title = "내 정보 입력"
    tableView.addGestureRecognizer(tableViewTapGesture)
    
    [ tableView, floatyBottomView ]
      .forEach { view.addSubview($0) }
    
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
}

extension OnboardingViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: OnboardingTableViewCell.identifier, for: indexPath) as? OnboardingTableViewCell else { return UITableViewCell() }
    let question = viewModel.getQuestionText(index: indexPath.row)
    let onboardingListType = OnboardingListType.allCases[indexPath.row]
    cell.configureUI(type: onboardingListType, question: question)
    
    cell.onChangedTextSubject
      .subscribe(onNext: { [weak self] text, type in
        guard let self = self else { return }
        switch onboardingListType {
        case .cleanup:
          self.viewModel.myInfo?.cleanUpStatus = text
        case .wakeup:
          self.viewModel.myInfo?.wakeupTime = text
        case .shower:
          self.viewModel.myInfo?.showerTime = text
        case .mbti:
          self.viewModel.myInfo?.mbti = text
        case .chatLink:
          self.viewModel.myInfo?.chatLink = text
        case .wishText:
          self.viewModel.myInfo?.wishText = text
        }
      })
      .disposed(by: disposeBag)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfRowsInSection
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: OnboardingTableHeaderView.identifier) as! OnboardingTableHeaderView
    
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
    
    return header
  }
}
