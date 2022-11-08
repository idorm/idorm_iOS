import UIKit

import SnapKit
import Then

final class MyRoommateViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let myRoommateVCType: MyRoommateVCType
  
  private lazy var tableView = UITableView().then {
    $0.allowsSelection = false
    $0.register(MyRoommateCell.self, forCellReuseIdentifier: MyRoommateCell.identifier)
    $0.dataSource = self
    $0.delegate = self
  }
  
  // MARK: - LifeCycle
  
  init(_ myRoommateVCType: MyRoommateVCType) {
    self.myRoommateVCType = myRoommateVCType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()

    switch myRoommateVCType {
    case .like:
      navigationItem.title = "좋아요한 룸메"
    case .dislike:
      navigationItem.title = "싫어요한 룸메"
    }
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    view.addSubview(tableView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
  }
}

// MARK: - TableView Setup

extension MyRoommateViewController: UITableViewDataSource, UITableViewDelegate {
  // Initialize Cell
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: MyRoommateCell.identifier,
      for: indexPath
    ) as? MyRoommateCell else {
      return UITableViewCell()
    }
    cell.setupMatchingInfomation(from: MatchingInfo.initialValue())
    return cell
  }
  
  // Number Of Cells
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 5
  }
  
  // Cell Height
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
    return 510
  }
  
  // Initialize Header
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = MyRoommateHeaderView()
    return header
  }
  
  // Header Height
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50
  }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct MyRoommateVC_PreView: PreviewProvider {
  static var previews: some View {
    MyRoommateViewController(.dislike).toPreview()
  }
}
#endif
