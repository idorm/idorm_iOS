//
//  MatchingFilterViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/30.
//

import SnapKit
import UIKit
import RxSwift
import RxCocoa

class MatchingFilterViewController: UIViewController {
  // MARK: - Properties
  lazy var tableView: UITableView = {
    let tv = UITableView(frame: .zero, style: .grouped)
    tv.register(OnboardingTableHeaderView.self, forHeaderFooterViewReuseIdentifier: OnboardingTableHeaderView.identifier)
    tv.backgroundColor = .white
    tv.sectionHeaderHeight = UITableView.automaticDimension
    tv.estimatedSectionHeaderHeight = 100
    tv.dataSource = self
    tv.delegate = self
    
    return tv
  }()
  
  private let floatyBottomView = FloatyBottomView(.filter)
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bind()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = true
    navigationController?.navigationBar.isHidden = false
  }

  // MARK: - Bind
  private func bind() {
    [ tableView, floatyBottomView ]
      .forEach { view.addSubview($0) }
    
    floatyBottomView.snp.makeConstraints { make in
      make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
      make.height.equalTo(84)
    }
    
    tableView.snp.makeConstraints { make in
      make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
      make.bottom.equalTo(floatyBottomView.snp.top)
    }
  }
  
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .white
    navigationItem.title = "필터"
  }
}

extension MatchingFilterViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: OnboardingTableHeaderView.identifier) as? OnboardingTableHeaderView else { return UIView() }
    header.configureUI(type: .matchingFilter)
    return header
  }
}
