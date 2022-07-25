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
  let viewModel = OnboardingListViewModel()
  var disposeBag = DisposeBag()
  var verifyConfirmButtonDict: [OnboardingVerifyType: Bool] = [
    .wakeup: false,
    .dorm: false,
    .gender: false,
    .age: false,
    .period: false,
    .cleanup: false,
    .shower: false
  ]
  
  let floatyBottomView = OnboardingFloatyBottomView()
  
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
  
  private func verfiyConfirmButton(bool: Bool, type: OnboardingVerifyType) {
    verifyConfirmButtonDict.updateValue(bool, forKey: type)
//    guard let wakeupCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? OnboardingTableViewCell else { return }
//    guard let cleanupCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? OnboardingTableViewCell else { return }
//    guard let showerCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? OnboardingTableViewCell else { return }
//    guard let header = tableView.headerView(forSection: 0) as? OnboardingTableHeaderView else { return }

  }
}

extension OnboardingViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: OnboardingTableViewCell.identifier, for: indexPath) as? OnboardingTableViewCell else { return UITableViewCell() }
    let question = viewModel.getQuestionText(index: indexPath.row)

    switch indexPath.row {
    case 3, 4: // 옵션
      cell.configureUI(type: .optional, question: question)
      return cell
    case 5: // 프리토킹
      cell.configureUI(type: .free, question: question)
      return cell
    default:
      cell.configureUI(type: .essential, question: question)
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfRowsInSection
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: OnboardingTableHeaderView.identifier) as! OnboardingTableHeaderView
    
    header.onChangedVerifyState
      .subscribe(onNext:{ [weak self] state, type in
        self?.verfiyConfirmButton(bool: state, type: type)
      })
      .disposed(by: disposeBag)
    
    return header
  }
}
