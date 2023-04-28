//
//  MyCommunityVC.swift
//  idorm
//
//  Created by 김응철 on 2023/04/27.
//

import UIKit

import SnapKit

final class MyCommunityViewController: BaseViewController {
  
  enum ViewControllerType {
    case post
    case comment
    case recommend
  }
  
  // MARK: - UI Components
  
  private lazy var tableView: UITableView = {
    let tb = UITableView()
    tb.register(
      MyPageSortHeaderView.self,
      forHeaderFooterViewReuseIdentifier: MyPageSortHeaderView.identifier
    )
    tb.delegate = self
    tb.dataSource = self
    return tb
  }()
  
  // MARK: - Properties
  
  private let viewControllerType: ViewControllerType
  
  // MARK: - Initializer
  
  init(viewControllerType: ViewControllerType) {
    self.viewControllerType = viewControllerType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    switch viewControllerType {
    case .comment:
      navigationItem.title = "내가 쓴 댓글"
    case .post:
      navigationItem.title = "내가 쓴 글"
    case .recommend:
      navigationItem.title = "공감한 글"
    }
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      tableView
    ].forEach {
      view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}

// MARK: - Setup TableView

extension MyCommunityViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    return UITableViewCell()
//    switch viewControllerType {
//    case .post, .recommend:
//      guard let cell = tableView.dequeueReusableCell(
//        withIdentifier: PostCell.identifier,
//        for: indexPath
//      ) as? PostCell else {
//        return UITableViewCell()
//      }
//      return cell
//
//    case .comment:
//      guard let cell = tableView.dequeueReusableCell(
//        withIdentifier: CommentCell.identifier,
//        for: indexPath
//      ) as? CommentCell else {
//        return UITableViewCell()
//      }
//      return cell
//    }
  }
  
  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
  ) -> Int {
    return 10
  }
}
