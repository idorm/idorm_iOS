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
          
        case .teamCalendar:
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TeamCalendarCell.identifier,
            for: indexPath
          ) as? TeamCalendarCell else {
            return UICollectionViewCell()
          }
          return cell
        default:
          return UICollectionViewCell()
        }
      }
    )
    dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
      guard
        let section = self.dataSource.sectionIdentifier(for: indexPath.section)
      else { fatalError("❌ CalendarSection을 찾을 수 없습니다!") }
      
      switch section {
      case .teamMembers:
        guard let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: CalendarMemberHeader.identifier,
          for: indexPath
        ) as? CalendarMemberHeader else {
          return UICollectionReusableView()
        }
        return header
      case .calendar:
        guard let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: CalendarHeader.identifier,
          for: indexPath
        ) as? CalendarHeader else {
          return UICollectionReusableView()
        }
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
  
  private lazy var collectionView: UICollectionView = {
    let layout = self.setupCompositionalLayout()
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.contentInsetAdjustmentBehavior = .never
    
    // Cell
    cv.register(
      CalendarMemberCell.self,
      forCellWithReuseIdentifier: CalendarMemberCell.identifier
    )
    cv.register(
      TeamCalendarCell.self,
      forCellWithReuseIdentifier: TeamCalendarCell.identifier
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
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    self.view.addSubview(self.collectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: CalendarViewReactor) {
    // Action
    self.rx.viewDidLoad
      .map { CalendarViewReactor.Action.viewDidLoad }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, sectionItem in
        var snapshot = NSDiffableDataSourceSnapshot<CalendarSection, CalendarSectionItem>()
        snapshot.appendSections(sectionItem.sections)
        sectionItem.items.enumerated().forEach { index, items in
          snapshot.appendItems(items, toSection: sectionItem.sections[index])
        }
        owner.dataSource.apply(snapshot, animatingDifferences: true)
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
          heightDimension: .absolute(80 + 18 + self.view.safeAreaInsets.top + 14)
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
          top: 18 + self.view.safeAreaInsets.top,
          leading: 24,
          bottom: 14,
          trailing: 14
        )
        section.decorationItems = [
          .background(elementKind: CalendarMemberBackgroundView.identifier)
        ]
        
        return section
      case .calendar:
        // Item
        let itemSize = NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(0)
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
          heightDimension: .absolute(18)
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
      default:
        fatalError()
      }
    }
  }
}
