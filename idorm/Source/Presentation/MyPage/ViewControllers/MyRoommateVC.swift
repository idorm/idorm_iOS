import UIKit

import RxSwift
import RxCocoa
import SnapKit
import PanModal
import Then

final class MyRoommateViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let vcType: MyPageVCTypes.MyRoommateVCType
  private let viewModel = MyRoommateViewModel()
  
  private let indicator = UIActivityIndicatorView().then {
    $0.color = .gray
  }
  
  private lazy var tableView = UITableView(frame: .zero, style: .grouped).then {
    $0.register(MyRoommateHeaderView.self, forHeaderFooterViewReuseIdentifier: MyRoommateHeaderView.identifier)
    $0.register(MyRoommateCell.self, forCellReuseIdentifier: MyRoommateCell.identifier)
    $0.backgroundColor = .idorm_gray_100
    $0.bounces = false
    $0.dataSource = self
    $0.delegate = self
  }
  
  private var header: MyRoommateHeaderView!
  
  // MARK: - LifeCycle
  
   init(_ vcType: MyPageVCTypes.MyRoommateVCType) {
    self.vcType = vcType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    view.backgroundColor = .idorm_gray_100
    switch vcType {
    case .like:
      navigationItem.title = "좋아요한 룸메"
    case .dislike:
      navigationItem.title = "싫어요한 룸메"
    }
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [tableView, indicator]
      .forEach { view.addSubview($0) }
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
  
  private func bindHeader() {
    
    // 최신순 버튼 클릭
    header.lastestButton.rx.tap
      .debug()
      .map { [weak self] in
        self?.header.lastestButton.isSelected = true
        self?.header.pastButton.isSelected = false
      }
      .bind(to: viewModel.input.lastestButtonDidTap)
      .disposed(by: disposeBag)
    
    // 과거순 버튼 클릭
    header.pastButton.rx.tap
      .map { [weak self] in
        self?.header.lastestButton.isSelected = false
        self?.header.pastButton.isSelected = true
      }
      .bind(to: viewModel.input.pastButtonDidTap)
      .disposed(by: disposeBag)
  }
  
  override func bind() {
    super.bind()
    
    // MARK: - Input
    
    // 화면 최초 접속 이벤트
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.viewModel.input.loadViewObserver.onNext(self.vcType)
    }
    
    // MARK: - Output
    
    // 인디케이터 애니메이션 반응
    viewModel.output.indicatorState
      .debug()
      .bind(onNext: { [weak self] in
        if $0 {
          self?.indicator.startAnimating()
          self?.view.isUserInteractionEnabled = false
        } else {
          self?.indicator.stopAnimating()
          self?.view.isUserInteractionEnabled = true
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
    cell.setupMatchingInfomation(from: viewModel.members[indexPath.row])
    cell.selectionStyle = .none
    return cell
  }
  
  // Number Of Cells
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.members.count
  }
  
  // Cell Height
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
    return 510
  }
  
  // Initialize Header
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let header = tableView.dequeueReusableHeaderFooterView(
      withIdentifier: MyRoommateHeaderView.identifier
    ) as? MyRoommateHeaderView else {
      return UIView()
    }

    if self.header == nil {
      self.header = header
      bindHeader()
    }

    return header
  }

  // Header Height
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50
  }
  
  // didSelectCell
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let bottomAlertType: MyPageVCTypes.MyPageBottomAlertVCType
    if vcType == .like {
      bottomAlertType = .like
    } else {
      bottomAlertType = .dislike
    }
    let viewController = MyPageBottomAlertViewController(bottomAlertType)
    presentPanModal(viewController)
    
    let matchingMember = viewModel.members[indexPath.row]
    
    // 멤버 삭제 버튼 클릭 이벤트
    viewController.deleteButton.rx.tap
      .map { [unowned self] in (self.vcType, matchingMember) }
      .bind(to: viewModel.input.deleteButtonTapped)
      .disposed(by: disposeBag)
    
    // AlertVC 끄기
    viewModel.output.dismissAlertVC
      .bind(onNext: {
        viewController.dismiss(animated: true)
      })
      .disposed(by: disposeBag)
  }
}
