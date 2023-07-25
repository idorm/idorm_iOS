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
          cell.configure(member)
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
    
    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.view.backgroundColor = .iDormColor(.iDormGray100)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.view.addSubview(self.collectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.collectionView.snp.makeConstraints { make in
      make.edges.equalTo(self.view.safeAreaLayoutGuide)
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
    
    // State
    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, sectionItem in
        var snapshot = NSDiffableDataSourceSnapshot<CalendarSection, CalendarSectionItem>()
        snapshot.appendSections(sectionItem.sections)
        sectionItem.items.enumerated().forEach { index, item in
          snapshot.appendItems(item, toSection: sectionItem.sections[index])
        }
        DispatchQueue.main.async {
          owner.dataSource.applySnapshotUsingReloadData(snapshot)
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
          heightDimension: .absolute(36)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        
        // Header
        let headerSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .absolute(50)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
          layoutSize: headerSize,
          elementKind: UICollectionView.elementKindSectionHeader,
          alignment: .top
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        section.interGroupSpacing = 6
        section.contentInsets = NSDirectionalEdgeInsets(
          top: 18,
          leading: 24,
          bottom: 18,
          trailing: 24
        )
        section.decorationItems = [
          .background(elementKind: TeamCalendarBackgroundView.identifier)
        ]
        
        return section
      default:
        // Item
        let itemSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .estimated(150)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        
        // Header
        let headerSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .absolute(40.0)
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
          bottom: 24,
          trailing: 24
        )
        
        return section
      }
    }
  }
  
  /// `inviteRoommateImageView`의 레이아웃 및 제약조건을 생성합니다.
  func setupInviteRoommateImageView() {
    self.view.addSubview(self.inviteRoommateImageView)
    
    self.inviteRoommateImageView.snp.makeConstraints { make in
      make.trailing.equalToSuperview().inset(44.0)
      make.top.equalTo(self.calendarMemberHeader.inviteButton.snp.bottom)
    }
  }
}

// MARK: - CalendarMemberHeader

extension CalendarViewController: CalendarMemberHeaderDelegate {
  /// 룸메이트 버튼이 눌렸을 때
  func didTapInviteRoommateButton() {}
  
  /// 옵션 버튼이 눌렸을 때
  func didTapOptionButton() {
    let bottomSheetVC = BottomSheetViewController(
      items: [
        .normal(title: "친구 관리"),
        .normal(title: "일정 관리"),
        .normal(title: "룸메이트 초대해서 일정 공유하기"),
        .normal(title: "일정 공유 캘린더 나가기")
        ],
      contentHeight: 224.0
    )
    bottomSheetVC.delegate = self
    self.presentPanModal(bottomSheetVC)
  }
}

// MARK: - CalendarHeader

extension CalendarViewController: iDormCalendarDelegate {
  /// 달력의 월이 바뀔 때 호출되는 메서드입니다.
  func monthDidChage(_ currentDateString: String) {
    self.reactor?.action.onNext(.currentDateDidChange(currentDateString))
  }
}

// MARK: - BottomSheet

extension CalendarViewController: BottomSheetViewControllerDelegate {
  /// 바텀 시트 버튼이 눌렸을 때
  func didTapButton(index: Int) {
    print(index)
  }
}
