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
  
  lazy var floatyBottomView = createFloatyBottomView()
  
  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.estimatedRowHeight = 100
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedSectionHeaderHeight = 100
    tableView.sectionHeaderHeight = UITableView.automaticDimension
    tableView.backgroundColor = .white
    tableView.separatorStyle = .none
    tableView.allowsSelection = false
    tableView.keyboardDismissMode = .onDrag
    tableView.register(OnboardingTableViewCell.self, forCellReuseIdentifier: OnboardingTableViewCell.identifier)
    tableView.register(OnboardingTableHeaderView.self, forHeaderFooterViewReuseIdentifier: OnboardingTableHeaderView.identifier)
    tableView.delegate = self
    tableView.dataSource = self
    
    return tableView
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
   
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .white
    navigationItem.title = "내 정보 입력"
    
    [ tableView, floatyBottomView ]
      .forEach { view.addSubview($0) }
    
    tableView.snp.makeConstraints { make in
      make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
      make.bottom.equalTo(floatyBottomView.snp.top)
    }
    
    floatyBottomView.snp.makeConstraints { make in
      make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
      make.leading.trailing.equalToSuperview()
    }
  }
  
  private func createFloatyBottomView() -> UIView {
    let view = UIView()
    view.backgroundColor = .white
    
    var skipConfig = UIButton.Configuration.filled()
    skipConfig.baseBackgroundColor = .blue_white
    skipConfig.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 26, bottom: 14, trailing: 26)
    
    var confirmConfig = UIButton.Configuration.filled()
    confirmConfig.baseBackgroundColor = .grey_custom
    confirmConfig.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 26, bottom: 14, trailing: 26)
    
    var skipContainer = AttributeContainer()
    skipContainer.font = .init(name: Font.medium.rawValue, size: 16)
    skipContainer.foregroundColor = .darkgrey_custom
    var confirmContainer = AttributeContainer()
    confirmContainer.foregroundColor = .white
    confirmContainer.font = .init(name: Font.medium.rawValue, size: 16)

    skipConfig.attributedTitle = AttributedString("정보 입력 건너 뛰기", attributes: skipContainer)
    confirmConfig.attributedTitle = AttributedString("완료", attributes: confirmContainer)
    
    let skipButton = UIButton(configuration: skipConfig)
    let confirmButton = UIButton(configuration: confirmConfig)
    
    skipButton.addTarget(self, action: #selector(didTapSkipButton), for: .touchUpInside)
    confirmButton.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
    
    [ confirmButton, skipButton ].forEach { view.addSubview($0) }
    
    view.snp.makeConstraints { make in
      make.height.equalTo(76)
    }
    
    skipButton.snp.makeConstraints { make in
      make.leading.equalToSuperview().inset(24)
      make.centerY.equalToSuperview()
    }
    
    confirmButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(24)
      make.centerY.equalToSuperview()
    }
    
    return view
  }
}

extension OnboardingViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: OnboardingTableViewCell.identifier, for: indexPath) as? OnboardingTableViewCell else { return UITableViewCell() }
    let question = viewModel.getQuestionText(index: indexPath.row)
    
    switch indexPath.row {
    case 3, 4:
      cell.configureUI(type: .optional, question: question)
      return cell
    case 5:
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
    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: OnboardingTableHeaderView.identifier)
    
    return header
  }
}
