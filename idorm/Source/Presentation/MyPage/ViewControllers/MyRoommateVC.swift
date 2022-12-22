import UIKit

import SnapKit
import PanModal
import Then
import RxSwift
import RxCocoa
import RxAppState
import ReactorKit

final class MyRoommateViewController: BaseViewController, View {
  
  typealias Reactor = MyRoommateViewReactor
  
  // MARK: - Properties
  
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
  
  private let roommate: MyPageEnumerations.Roommate
  private let viewModel = MyRoommateViewModel()
  private var reactor = MyRoommateViewReactor()
  private var header: MyRoommateHeaderView!
  
  // MARK: - LifeCycle
  
  init(_ roommate: MyPageEnumerations.Roommate) {
    self.roommate = roommate
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Bind
  
  func bind(reactor: MyRoommateViewReactor) {
    
    // MARK: - Action
    
    // viewDidLoad
    Observable.just(1)
      .withUnretained(self)
      .map { MyRoommateViewReactor.Action.viewDidLoad($0.0.roommate) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // MARK: - State
    
    // 로딩 중
    reactor.state
      .map { $0.isLoading }
      .distinctUntilChanged()
      .bind(to: indicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    // 현재 정렬
    reactor.state
      .map { $0.currentSort }
      .distinctUntilChanged()
      .withUnretained(self)
      .bind { owner, sort in
        switch sort {
        case .lastest:
          owner.header.lastestButton.isSelected = true
          owner.header.pastButton.isSelected = false
        case .past:
          owner.header.lastestButton.isSelected = false
          owner.header.pastButton.isSelected = true
        }
      }
      .disposed(by: disposeBag)
    
    // 테이블 뷰 리로드
    reactor.state
      .map { $0.reloadData }
      .distinctUntilChanged()
      .filter { $0 }
      .withUnretained(self)
      .bind { $0.0.tableView.reloadData() }
      .disposed(by: disposeBag)
    
    // 팝업창 열기
    reactor.state
      .map { $0.isOpenedPopup }
      .distinctUntilChanged()
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let popup = BasicPopup(contents: "링크가 유효하지 않습니다.")
        popup.modalPresentationStyle = .overFullScreen
        owner.present(popup, animated: false)
      }
      .disposed(by: disposeBag)
    
    // 사파리 열기
    reactor.state
      .map { $0.isOpenedSafari }
      .filter { $0.0 }
      .bind { UIApplication.shared.open(URL(string: $0.1)!) }
      .disposed(by: disposeBag)
  }
  
  private func bindHeader() {
    
    // 최신순 버튼 클릭
    header.lastestButton.rx.tap
      .map { MyRoommateViewReactor.Action.didTapLastestButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 과거순 버튼 클릭
    header.pastButton.rx.tap
      .map { MyRoommateViewReactor.Action.didTapPastButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    view.backgroundColor = .idorm_gray_100
    switch roommate {
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
}

// MARK: - TableView Setup

extension MyRoommateViewController: UITableViewDataSource, UITableViewDelegate {
  // Initialize Cell
  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: MyRoommateCell.identifier,
      for: indexPath
    ) as? MyRoommateCell else {
      return UITableViewCell()
    }
    cell.setupMatchingInfomation(from: reactor.currentState.currentMembers[indexPath.row])
    cell.selectionStyle = .none
    return cell
  }
  
  // Number Of Cells
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return reactor.currentState.currentMembers.count
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
    let bottomSheet: MyRoommaateBottomSheet
    let member = reactor.currentState.currentMembers[indexPath.row]
    switch roommate {
    case .like:
      bottomSheet = MyRoommaateBottomSheet(.like)
    case .dislike:
      bottomSheet = MyRoommaateBottomSheet(.dislike)
    }
    presentPanModal(bottomSheet)
    
    // 삭제버튼 클릭
    bottomSheet.deleteButton.rx.tap
      .withUnretained(self)
      .map { ($0.0.roommate, member.memberId) }
      .map { MyRoommateViewReactor.Action.didTapDeleteButton($0.0 , $0.1) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // 룸메이트 채팅 하기
    bottomSheet.chatButton.rx.tap
      .map { MyRoommateViewReactor.Action.didTapChatButton(member.openKakaoLink) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
        
    // 바텀시트 닫기
    reactor.state
      .map { $0.isOpenedBottomSheet }
      .distinctUntilChanged()
      .bind { _ in bottomSheet.dismiss(animated: true) }
      .disposed(by: disposeBag)
  }
}
