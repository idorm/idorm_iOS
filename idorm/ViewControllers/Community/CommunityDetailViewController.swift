//
//  CommunityDetailViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/20.
//

import UIKit
import SnapKit
import RSKGrowingTextView

class CommunityDetailViewController: UIViewController {
  // MARK: - Properties
  lazy var commentsTextView: RSKGrowingTextView = {
    let textView = RSKGrowingTextView()
    textView.attributedPlaceholder = NSAttributedString(string: "댓글을 입력해주세요.", attributes: [NSAttributedString.Key.font: UIFont.init(name: Font.regular.rawValue, size: 12) ?? 0, NSAttributedString.Key.foregroundColor: UIColor.darkgrey_custom])
    textView.layer.cornerRadius = 15
    textView.backgroundColor = .init(rgb: 0xF4F2FA)
    textView.isScrollEnabled = false
    textView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    
    return textView
  }()
  
  lazy var sendCommentButton: UIButton = {
    let btn = UIButton(type: .custom)
    btn.setImage(UIImage(named: "sendComments"), for: .normal)
    btn.setContentHuggingPriority(.init(rawValue: 251), for: .horizontal)
    
    return btn
  }()
  
  lazy var bottomView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    
    return view
  }()
  
  lazy var optionButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(UIImage(named: "option"), for: .normal)
    
    return button
  }()
  
  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.backgroundColor = .white
    tableView.register(CommunityDetailTableViewCell.self, forCellReuseIdentifier: CommunityDetailTableViewCell.identifier)
    tableView.estimatedRowHeight = 100
    tableView.estimatedSectionHeaderHeight = 100
    tableView.rowHeight = UITableView.automaticDimension
    tableView.sectionHeaderHeight = UITableView.automaticDimension
    tableView.dataSource = self
    tableView.delegate = self
    
    return tableView
  }()
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }
  
  // MARK: - Selectors
  
  // MARK: - Helpers
  private func configureUI() {
    tabBarController?.tabBar.isHidden = true
    view.backgroundColor = .white
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: optionButton)
    
    [ bottomView, commentsTextView, sendCommentButton, tableView ]
      .forEach { view.addSubview($0) }
    
    commentsTextView.snp.makeConstraints { make in
      make.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-16)
      make.leading.equalToSuperview().inset(24)
      make.trailing.equalTo(sendCommentButton.snp.leading).offset(-16)
    }

    sendCommentButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(24)
      make.leading.equalTo(commentsTextView.snp.trailing).offset(16)
      make.centerY.equalTo(commentsTextView)
    }
    
    bottomView.snp.makeConstraints { make in
      make.bottom.leading.trailing.equalToSuperview()
      make.top.equalTo(commentsTextView.snp.top).offset(-8)
    }
    
    tableView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}

extension CommunityDetailViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: CommunityDetailTableViewCell.identifier, for: indexPath) as? CommunityDetailTableViewCell else { return UITableViewCell() }
    cell.backgroundColor = .mainColor
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = CommunityDetailTableHeaderView()
    header.configureUI()
    
    return header
  }
}
