//
//  CalandarViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/17.
//

import UIKit
import SnapKit
import FSCalendar

class CalendarViewController: UIViewController {
  // MARK: - Properties
  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.backgroundColor = .white
    tableView.allowsSelection = false
    tableView.separatorStyle = .none
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(MainCalendarTableHeaderView.self, forHeaderFooterViewReuseIdentifier: MainCalendarTableHeaderView.identifier)
    tableView.register(PersonalCalendarTableHeaderView.self, forHeaderFooterViewReuseIdentifier: PersonalCalendarTableHeaderView.identifier)
    tableView.register(DormCalendarTableHeaderView.self, forHeaderFooterViewReuseIdentifier: DormCalendarTableHeaderView.identifier)
    tableView.register(CalendarChipTableViewCell.self, forCellReuseIdentifier: CalendarChipTableViewCell.identifier)
    tableView.register(CalendarPersonalTableViewCell.self, forCellReuseIdentifier: CalendarPersonalTableViewCell.identifier)
    tableView.register(CalendarDormTableViewCell.self, forCellReuseIdentifier: CalendarDormTableViewCell.identifier)
    
    return tableView
  }()
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.isHidden = true
  }
  
  // MARK: - Helpers
  private func configureUI() {
    navigationController?.navigationBar.isHidden = true
    view.backgroundColor = .white
    
    view.addSubview(tableView)
  
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
  }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case CalendarListType.chip.listIndex:
      guard let chipCell = tableView.dequeueReusableCell(withIdentifier: CalendarChipTableViewCell.identifier, for: indexPath) as? CalendarChipTableViewCell else { return UITableViewCell() }
      chipCell.configureUI()
      return chipCell
    case CalendarListType.personal.listIndex:
      guard let personalCell = tableView.dequeueReusableCell(withIdentifier: CalendarPersonalTableViewCell.identifier, for: indexPath) as? CalendarPersonalTableViewCell else { return UITableViewCell() }
      personalCell.configureUI()
      return personalCell
    case CalendarListType.dorm.listIndex:
      guard let dormCell = tableView.dequeueReusableCell(withIdentifier: CalendarDormTableViewCell.identifier, for: indexPath) as? CalendarDormTableViewCell else { return UITableViewCell() }
      dormCell.configureUI()
      return dormCell
    default:
      return UITableViewCell()
    }
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return CalendarListType.allCases.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case CalendarListType.chip.listIndex :
      return 1
    case CalendarListType.personal.listIndex:
      return 10
    case CalendarListType.dorm.listIndex:
      return 10
    default:
      return 0
    }
  }
  
  /// header dequeueReusable
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    switch section {
    case CalendarListType.chip.listIndex:
      guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: MainCalendarTableHeaderView.identifier) as? MainCalendarTableHeaderView else { return UIView() }
      header.configureUI()
      return header
    case CalendarListType.personal.listIndex:
      guard let personalHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: PersonalCalendarTableHeaderView.identifier) as? PersonalCalendarTableHeaderView else { return UIView() }
      personalHeader.configureUI()
      return personalHeader
    case CalendarListType.dorm.listIndex:
      guard let dormHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: DormCalendarTableHeaderView.identifier) as? DormCalendarTableHeaderView else { return UIView() }
      dormHeader.configureUI()
      return dormHeader
    default:
      return UIView()
    }
  }
  
  /// header Height
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 320
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch indexPath.section {
    case CalendarListType.chip.listIndex:
      return 30
    default:
      return 36
    }
  }
}

