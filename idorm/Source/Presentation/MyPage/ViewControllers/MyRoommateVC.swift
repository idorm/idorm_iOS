import UIKit

import SnapKit
import PanModal
import Then
import RxSwift
import RxCocoa
import RxAppState

final class MyRoommateViewController: BaseViewController {
  
  // MARK: - Properties
  
  private let vcType: MyPageEnumerations.Roommate
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
  
  init(_ vcType: MyPageEnumerations.Roommate) {
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
      .map { MyRoommateSortType.lastest }
      .bind(to: viewModel.input.lastestButtonDidTap)
      .disposed(by: disposeBag)
    
    // 과거순 버튼 클릭
    header.pastButton.rx.tap
      .map { MyRoommateSortType.past }
      .bind(to: viewModel.input.pastButtonDidTap)
      .disposed(by: disposeBag)
  }
  
  override func bind() {
    super.bind()
    
    // MARK: - Input
    
    // 화면 최초 접속 이벤트
    rx.viewWillAppear
      .take(1)
      .withUnretained(self)
      .map { $0.0.vcType }
      .bind(to: viewModel.input.viewWillAppear)
      .disposed(by: disposeBag)
    
    // MARK: - Output
    
    // 버튼 토글
    viewModel.output.toggleSortButton
      .withUnretained(self)
      .bind(onNext: { owner, type in
        switch type {
        case .lastest:
          owner.header.lastestButton.isSelected = true
          owner.header.pastButton.isSelected = false
        case .past:
          owner.header.lastestButton.isSelected = false
          owner.header.pastButton.isSelected = true
        }
      })
      .disposed(by: disposeBag)
    
    // 인디케이터 애니메이션
    viewModel.output.isLoading
      .bind(to: indicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    // 화면 인터렉션 제어
    viewModel.output.isLoading
      .map { !$0 }
      .bind(to: view.rx.isUserInteractionEnabled)
      .disposed(by: disposeBag)
    
    // 테이블뷰 정보 불러오기
    viewModel.output.reloadData
      .withUnretained(self)
      .map { $0.0 }
      .bind(onNext: { $0.tableView.reloadData() })
      .disposed(by: disposeBag)
    
    // 오류 팝업
    viewModel.output.presentPopup
      .withUnretained(self)
      .debug()
      .bind {
        let popup = BasicPopup(contents: $0.1)
        popup.modalPresentationStyle = .overFullScreen
        $0.0.present(popup, animated: false)
      }
      .disposed(by: disposeBag)
    
    // 사파리로 이동
    viewModel.output.presentSafari
      .bind { UIApplication.shared.open($0) }
      .disposed(by: disposeBag)
    
    // 카카오톡 링크 팝업
    viewModel.output.presentKakaoPopup
      .withUnretained(self)
      .bind { owner, link in
        let popup = KakaoPopup()
        popup.modalPresentationStyle = .overFullScreen
        owner.present(popup, animated: false)
        
        // 카카오 링크 바로가기 버튼 클릭
        popup.kakaoButton.rx.tap
          .map { link }
          .bind(to: owner.viewModel.input.kakaoLinkButtonDidTap)
          .disposed(by: owner.disposeBag)
        
        // 팝업창 닫기
        owner.viewModel.output.dismissKakaoPopup
          .bind { popup.dismiss(animated: false) }
          .disposed(by: owner.disposeBag)
      }
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
    cell.setupMatchingInfomation(from: viewModel.currentMembers.value[indexPath.row])
    cell.selectionStyle = .none
    return cell
  }
  
  // Number Of Cells
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.currentMembers.value.count
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
    let viewController = MyRoommateBottomAlertViewController(bottomAlertType)
    presentPanModal(viewController)
    
    let matchingMember = viewModel.currentMembers.value[indexPath.row]
    
    // 멤버 삭제 버튼 클릭 이벤트
    viewController.deleteButton.rx.tap
      .withUnretained(self)
      .map { ($0.0.vcType, matchingMember) }
      .bind(to: viewModel.input.deleteButtonDidTap)
      .disposed(by: disposeBag)
    
    // 룸메이트와 채팅하기 버튼 클릭 이벤트
    viewController.chatButton.rx.tap
      .map { indexPath.row }
      .bind(to: viewModel.input.chatButtonDidTap)
      .disposed(by: disposeBag)
    
    // AlertVC 종료
    viewModel.output.dismissAlertVC
      .bind(onNext: { viewController.dismiss(animated: true) })
      .disposed(by: disposeBag)
  }
}
