//
//  CalendarVC.swift
//  idorm
//
//  Created by 김응철 on 7/8/23.
//

import UIKit

import FSCalendar
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa
import RxGesture
import PanModal

final class CalendarViewController: BaseViewController, View {
  
  typealias DataSource = UICollectionViewDiffableDataSource<CalendarSection, CalendarSectionItem>
  
  // MARK: - Properties
  
  private lazy var dataSource: DataSource = {
    let dataSource = DataSource(
      collectionView: self.collectionView,
      cellProvider: { collectionView, indexPath, item in
        switch item {
        case .teamMember(let member):
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CalendarMemberCell.identifier,
            for: indexPath
          ) as? CalendarMemberCell else {
            return UICollectionViewCell()
          }
          cell.configure(with: member)
          return cell
          
        case .teamCalendar(let teamCalendar):
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TeamCalendarCell.identifier,
            for: indexPath
          ) as? TeamCalendarCell else {
            return UICollectionViewCell()
          }
          cell.configure(teamCalendar)
          return cell
          
        case .dormCalendar(let dormCalendar):
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DormCalendarCell.identifier,
            for: indexPath
          ) as? DormCalendarCell else {
            return UICollectionViewCell()
          }
          cell.configure(with: dormCalendar)
          return cell
          
        case .dormEmpty:
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DormCalendarEmptyCell.identifier,
            for: indexPath
          ) as? DormCalendarEmptyCell else {
            return UICollectionViewCell()
          }
          return cell
        }
      }
    )
    dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
      guard
        let section = self.dataSource.sectionIdentifier(for: indexPath.section),
        let reactor = self.reactor
      else { fatalError("❌ CalendarSection을 찾을 수 없습니다!") }
      
      switch section {
      case .teamMembers(let members):
        guard let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: CalendarMemberHeader.identifier,
          for: indexPath
        ) as? CalendarMemberHeader else {
          return UICollectionReusableView()
        }
        if self.calendarMemberHeader == nil {
          self.calendarMemberHeader = header
        }
        header.configure(with: members)
        header.delegate = self
        return header
        
      case let .calendar(teamCalendars, dormCalendars):
        guard let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: CalendarHeader.identifier,
          for: indexPath
        ) as? CalendarHeader else {
          return UICollectionReusableView()
        }
        header.calendarView.delegate = self
        header.configure(
          reactor.currentState.currentDate,
          teamCalendars: teamCalendars,
          dormCalendars: dormCalendars
        )
        return header
        
      case .dormCalendar, .teamCalendar:
        guard let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: CalendarScheduleHeader.identifier,
          for: indexPath
        ) as? CalendarScheduleHeader else {
          return UICollectionReusableView()
        }
        header.configure(section.headerContent)
        return header
      }
    }
    
    return dataSource
  }()
  
  // MARK: - UI Components
  
  /// `일정 등록` 플로티 `UIButton`
  private let registerScheduleButton: UIButton = {
    let button = iDormButton("일정 등록", image: .iDormIcon(.pencil))
    button.cornerRadius = 47.0
    button.baseBackgroundColor = .iDormColor(.iDormBlue)
    button.baseForegroundColor = .white
    button.font = .iDormFont(.bold, size: 16.0)
    button.shadowOffset = CGSize(width: 0, height: 4)
    button.shadowOpacity = 0.21
    button.shadowRadius = 3.0
    button.edgeInsets = .init(top: 10.0, leading: 18.0, bottom: 10.0, trailing: 18.0)
    return button
  }()
  
  /// `룸메이트를 초대해서 일정을 공유해보세요.`라는 문구가 적혀있는 `UIImageView`
  private let inviteRoommateImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .iDormText(.inviteRoommate)
    return imageView
  }()
  
  /// `calendarMemberHeader`를 참조할 수 있도록 만든 프로퍼티
  private var calendarMemberHeader: CalendarMemberHeader!
  
  /// 메인이 되는 `CollectionView`
  private lazy var collectionView: UICollectionView = {
    let layout = self.setupCompositionalLayout()
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.backgroundColor = .white
    
    // Cell
    cv.register(
      CalendarMemberCell.self,
      forCellWithReuseIdentifier: CalendarMemberCell.identifier
    )
    cv.register(
      TeamCalendarCell.self,
      forCellWithReuseIdentifier: TeamCalendarCell.identifier
    )
    cv.register(
      DormCalendarCell.self,
      forCellWithReuseIdentifier: DormCalendarCell.identifier
    )
    cv.register(
      DormCalendarEmptyCell.self,
      forCellWithReuseIdentifier: DormCalendarEmptyCell.identifier
    )
    
    // Header
    cv.register(
      CalendarMemberHeader.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: CalendarMemberHeader.identifier
    )
    cv.register(
      CalendarHeader.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: CalendarHeader.identifier
    )
    cv.register(
      CalendarScheduleHeader.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: CalendarScheduleHeader.identifier
    )
    
    // Decoration
    layout.register(
      CalendarMemberBackgroundView.self,
      forDecorationViewOfKind: CalendarMemberBackgroundView.identifier
    )
    layout.register(
      TeamCalendarBackgroundView.self,
      forDecorationViewOfKind: TeamCalendarBackgroundView.identifier
    )
    
    return cv
  }()
  
  // MARK: - Life Cycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.view.backgroundColor = .iDormColor(.iDormGray100)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.collectionView,
      self.registerScheduleButton
    ].forEach { self.view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.collectionView.snp.makeConstraints { make in
      make.edges.equalTo(self.view.safeAreaLayoutGuide)
    }
    
    self.registerScheduleButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-24.0)
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: CalendarViewReactor) {
    // Action
    self.rx.viewDidLoad
      .map { _ in CalendarViewReactor.Action.requestAllData }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.collectionView.rx.itemSelected
      .withUnretained(self)
      .map { owner, indexPath in
        let snapshot = owner.dataSource.snapshot()
        let sections = snapshot.sectionIdentifiers
        let items = snapshot.itemIdentifiers(inSection: sections[indexPath.section])
        return CalendarViewReactor.Action.itemSelected(items[indexPath.item])
      }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.inviteRoommateImageView.rx.tapGesture()
      .skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
          owner.inviteRoommateImageView.alpha = 0
        }
      }
      .disposed(by: self.disposeBag)
    
    self.registerScheduleButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        // 일정 등록 화면 전환
        let calendarDimmedVC = CalendarDimmedViewController(self.view.safeAreaInsets.bottom)
        calendarDimmedVC.delegate = owner
        calendarDimmedVC.modalPresentationStyle = .overFullScreen
        owner.present(calendarDimmedVC, animated: false)
      }
      .disposed(by: self.disposeBag)
    
    // State
    
    /// 새로운 데이터로 `snapshot`을 업데이트합니다.
    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, sectionItem in
        var snapshot = NSDiffableDataSourceSnapshot<CalendarSection, CalendarSectionItem>()
        snapshot.appendSections(sectionItem.sections)
        sectionItem.items.enumerated().forEach { index, item in
          snapshot.appendItems(item, toSection: sectionItem.sections[index])
        }
        DispatchQueue.main.async {
          owner.dataSource.apply(snapshot)
        }
      }
      .disposed(by: self.disposeBag)

    reactor.state
      .flatMap {
        Observable.combineLatest(
          Observable.just($0.isNeedToConfirmDeleted),
          Observable.just($0.members)
        )
      }
      .skip(1)
      .filter { $0.0 == false }
      .filter { $0.1.count == 1 }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.setupInviteRoommateImageView()
      }
      .disposed(by: self.disposeBag)
    
    /// `CalendarManagement`로 이동합니다.
    reactor.pulse(\.$navigateToCalendarMaanagementVC)
      .compactMap { $0 }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, calendarData in
        let viewController = CalendarManagementViewController()
        let reactor = CalendarManagementViewReactor(
          with: calendarData.0,
          teamMembers: calendarData.1
        )
        viewController.hidesBottomBarWhenPushed = true
        viewController.reactor = reactor
        viewController.delegate = owner
        owner.navigationController?.pushViewController(viewController, animated: true)
      }
      .disposed(by: self.disposeBag)
  }
}

// MARK: - Privates

private extension CalendarViewController {
  /// `CollectionView`의 레이아웃을 설정합니다.
  func setupCompositionalLayout() -> UICollectionViewCompositionalLayout {
     return UICollectionViewCompositionalLayout { section, _ in
      guard
        let calendarSection = self.dataSource.sectionIdentifier(for: section)
      else { fatalError("CalendarSection을 찾을 수 없습니다.") }
      
      switch calendarSection {
      case .teamMembers:
        // Item
        let itemSize = NSCollectionLayoutSize(
          widthDimension: .absolute(48),
          heightDimension: .absolute(80)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        
        // Header
        let headerSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .absolute(112.0)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
          layoutSize: headerSize,
          elementKind: UICollectionView.elementKindSectionHeader,
          alignment: .trailing
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        section.orthogonalScrollingBehavior = .paging
        section.interGroupSpacing = 20.0
        section.contentInsets = NSDirectionalEdgeInsets(
          top: 18,
          leading: 24,
          bottom: 14,
          trailing: 14
        )
        section.decorationItems = [
          .background(elementKind: CalendarMemberBackgroundView.identifier)
        ]
        
        section.visibleItemsInvalidationHandler = { _, offset, _ in
          self.collectionView.bounces = offset.y > 30
        }
        
        return section
      case .calendar:
        // Item
        let itemSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        
        // Header
        let headerSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .absolute(290)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
          layoutSize: headerSize,
          elementKind: UICollectionView.elementKindSectionHeader,
          alignment: .top
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        
        return section
      case .teamCalendar:
        // Item
        let itemSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(51)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        
        // Header
        let headerSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .absolute(45.0)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
          layoutSize: headerSize,
          elementKind: UICollectionView.elementKindSectionHeader,
          alignment: .top
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        section.interGroupSpacing = 18.0
        section.contentInsets = NSDirectionalEdgeInsets(
          top: 18.0,
          leading: 24.0,
          bottom: 18.0,
          trailing: 24.0
        )
        section.decorationItems = [
          .background(elementKind: TeamCalendarBackgroundView.identifier)
        ]
        
        return section
      default:
        // Item
        let itemSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .estimated(200.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        
        // Header
        let headerSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .absolute(45.0)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
          layoutSize: headerSize,
          elementKind: UICollectionView.elementKindSectionHeader,
          alignment: .top
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        section.contentInsets = NSDirectionalEdgeInsets(
          top: 0,
          leading: 24,
          bottom: 44 + 48,
          trailing: 24
        )
        
        return section
      }
    }
  }
  
  /// `inviteRoommateImageView`의 레이아웃 및 제약조건을 생성합니다.
  func setupInviteRoommateImageView() {
    self.view.insertSubview(self.inviteRoommateImageView, aboveSubview: self.collectionView)
    
    self.inviteRoommateImageView.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(44.0)
      make.top.equalTo(self.calendarMemberHeader.inviteButton.snp.bottom).offset(8.0)
    }
  }
}

// MARK: - CalendarMemberHeader

extension CalendarViewController: CalendarMemberHeaderDelegate {
  /// 룸메이트 버튼이 눌렸을 때
  func didTapInviteRoommateButton() {}
  
  /// 옵션 버튼이 눌렸을 때
  func didTapOptionButton() {
    let bottomSheetVC = BottomSheetViewController(items: [
      .manageFriend, .manageCalendar, .shareCalendar, .exitCalendar
    ])
    bottomSheetVC.delegate = self
    self.presentPanModal(bottomSheetVC)
  }
}

// MARK: - CalendarHeader

extension CalendarViewController: iDormCalendarViewDelegate {
  /// 달력의 월이 바뀔 때 호출되는 메서드입니다.
  func monthDidChage(_ currentDateString: String) {
    self.reactor?.action.onNext(.currentDateDidChange(currentDateString))
  }
}

// MARK: - BottomSheetViewControllerDelegate

extension CalendarViewController: BottomSheetViewControllerDelegate {
  /// 바텀 시트 버튼이 눌렸을 때
  func didTapButton(_ item: BottomSheetItem) {
    switch item {
    case .manageFriend:
      break
    case .manageCalendar:
      break
    case .shareCalendar:
      break
    case .exitCalendar:
      let iDormPopupVC = iDormPopupViewController(viewType: .twoButton(
        contents: "일정 공유 캘린더에서 나갈 시 데이터가 모두 사라집니다.",
        buttonTitle: "확인",
        identifier: "ExitCalendar"
      ))
      iDormPopupVC.modalPresentationStyle = .overFullScreen
      iDormPopupVC.delegate = self
      self.present(iDormPopupVC, animated: false)
    default: break
    }
  }
}

// MARK: - CalendarDimmedVC

extension CalendarViewController: CalendarDimmedViewControllerDelegate {
  /// 우리방 일정 클릭
  func didTapRegisterTeamScheduleButton() {
    self.reactor?.action.onNext(.registerScheduleButtonDidTap)
  }
  
  /// 외박 일정 클릭
  func didTapRegisterSleepOverButton() {}
}

// MARK: - CalendarManagementViewControllerDelegate

extension CalendarViewController: CalendarManagementViewControllerDelegate {
  /// 변경된 데이터로 인해 다시 한번 요청합니다.
  func shouldRequestData() {
    self.reactor?.action.onNext(.requestAllData)
  }
}

// MARK: - iDormPopupViewControllerDelegate

extension CalendarViewController: iDormPopupViewControllerDelegate {
  func confirmButtonDidTap(identifier: String) {
    switch identifier {
    case "ExitCalendar":
      self.reactor?.action.onNext(.exitCalendarButtonDidTap)
    default:
      break
    }
  }
}
