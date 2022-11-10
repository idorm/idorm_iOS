import UIKit

import RxSwift
import RxCocoa
import SnapKit
import PanModal
import Then

final class MyRoommateViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let myRoommateVCType: MyRoommateVCType
  private let viewModel = MyRoommateViewModel()
  private let indicator = UIActivityIndicatorView()
  
  private lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
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
  
  override func loadView() {
    super.loadView()
    
    // 화면 최초 접속 이벤트
    viewModel.input.loadViewObserver.onNext(myRoommateVCType)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()

    view.backgroundColor = .idorm_gray_100
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
    view.addSubview(indicator)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  // MARK: - Bind
  
  override func bind() {
    super.bind()
    
    // MARK: - Input
    
    // MARK: - Output
    
    // 인디케이터 애니메이션 반응
    viewModel.output.indicatorState
      .bind(onNext: { [weak self] in
        if $0 {
          self?.indicator.startAnimating()
        } else {
          self?.indicator.stopAnimating()
        }
      })
      .disposed(by: disposeBag)
    
    // 테이블뷰 정보 불러오기
    viewModel.output.reloadData
      .bind(onNext: { [weak self] in
        self?.tableView.reloadData()
      })
      .disposed(by: disposeBag)
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
    cell.setupMatchingInfomation(from: viewModel.matchingMembers[indexPath.row])
    cell.selectionStyle = .none
    return cell
  }
  
  // Number Of Cells
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.matchingMembers.count
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
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let bottomAlertType: MyPageBottomAlertVCType
    if myRoommateVCType == .like {
      bottomAlertType = .like
    } else {
      bottomAlertType = .dislike
    }
    let viewController = MyPageBottomAlertViewController(bottomAlertType)
    presentPanModal(viewController)
    
    let matchingMember = viewModel.matchingMembers[indexPath.row]
    
    // 멤버 삭제 버튼 클릭 이벤트
    viewController.deleteButton.rx.tap
      .map { [unowned self] in (self.myRoommateVCType, matchingMember) }
      .bind(to: viewModel.input.deleteButtonTapped)
      .disposed(by: disposeBag)
  }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct MyRoommateVC_PreView: PreviewProvider {
  static var previews: some View {
    MyRoommateViewController(.dislike).toPreview()
  }
}
#endif
