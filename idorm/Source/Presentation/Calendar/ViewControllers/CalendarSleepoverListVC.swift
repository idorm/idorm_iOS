//
//  CalendarSleepoverListVC.swift
//  idorm
//
//  Created by 김응철 on 8/17/23.
//

import UIKit

import ReactorKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

protocol CalendarSleepoverListViewControllerDelegate: AnyObject {
  func didDismissedViewController()
}

final class CalendarSleepoverListViewController: BaseViewController, View {
  
  typealias DataSource = UICollectionViewDiffableDataSource<CalendarSleepoverListSection, CalendarSleepoverListSectionItem>
  typealias Reactor = CalendarSleepoverListViewReactor
  
  // MARK: - UI Components
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: self.getLayout()
    )
    collectionView.layer.cornerRadius = 14.0
    // Register
    collectionView.register(
      CalendarSleepoverListCell.self,
      forCellWithReuseIdentifier: CalendarSleepoverListCell.identifier
    )
    collectionView.register(
      CalendarScheduleHeader.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: CalendarScheduleHeader.identifier
    )
    return collectionView
  }()
  
  // MARK: - Properties
  
  private lazy var dataSource: DataSource = {
    let dataSource = DataSource(
      collectionView: self.collectionView,
      cellProvider: { collectionView, indexPath, item in
        switch item {
        case let .sleepover(calendar, isEditing, isMyOwnCalendar):
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CalendarSleepoverListCell.identifier,
            for: indexPath
          ) as? CalendarSleepoverListCell else {
            return UICollectionViewCell()
          }
          cell.configure(with: calendar, isEditing: isEditing, isMyOwnCalendar: isMyOwnCalendar)
          return cell
        }
      }
    )
    dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
      guard let section = self.dataSource.sectionIdentifier(for: indexPath.section) else {
        fatalError("🔴 CalendarSleepoverListSection을 찾을 수 없습니다!")
      }
      switch section {
      case let .sleepover(canEdit):
        guard let header = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: CalendarScheduleHeader.identifier,
          for: indexPath
        ) as? CalendarScheduleHeader else {
          return UICollectionReusableView()
        }
        header.delegate = self
        header.configure(.Sleepover(canEdit: canEdit))
        return header
      }
    }
    return dataSource
  }()
  
  private var collectionViewHeightConstraint: Constraint?
  weak var delegate: CalendarSleepoverListViewControllerDelegate?
  
  // MARK: - Life Cycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    self.view.backgroundColor = .black.withAlphaComponent(0.5)
  }
  
  override func setupLayouts() {
    self.setupStyles()
    self.view.addSubview(self.collectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    self.collectionView.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      self.collectionViewHeightConstraint = make.height.equalTo(100.0).constraint
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: CalendarSleepoverListViewReactor) {
    // Action
    self.collectionView.rx.itemSelected
      .compactMap { self.dataSource.itemIdentifier(for: $0) }
      .withUnretained(self)
      .map { owner, item in
        switch item {
        case let .sleepover(_, isEditing, _):
          if isEditing {
            owner.presentToRemovalCalendarPopupVC(item)
            return .doNoting
          } else {
            return .itemSelected(item)
          }
        }
      }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, sectionData in
        var snapshot = NSDiffableDataSourceSnapshot<CalendarSleepoverListSection, CalendarSleepoverListSectionItem>()
        snapshot.appendSections(sectionData.sections)
        snapshot.appendItems(sectionData.items)
        DispatchQueue.main.async {
          owner.dataSource.apply(snapshot)
          let height = (sectionData.items.count * 58) + 60
          owner.collectionViewHeightConstraint?.update(offset: height)
        }
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$navigateToCalendarSleepoverManagementVC)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, teamCalendar in
        let viewController = CalendarSleepoverManagementViewController()
        let reactor = CalendarSleepoverManagementViewReactor(.edit(teamCalendar))
        viewController.reactor = reactor
        owner.navigationController?.pushViewController(viewController, animated: true)
      }
      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Functions
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    self.dismiss(animated: false)
    self.delegate?.didDismissedViewController()
  }
}

// MARK: - Privates

private extension CalendarSleepoverListViewController {
  func getLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout { section, _ in
      guard let section = self.dataSource.sectionIdentifier(for: section) else {
        fatalError("🔴 CalendarSleepoverListSection을 발견할 수 없습니다!")
      }
      return section.section
    }
  }
  
  func presentToRemovalCalendarPopupVC(_ item: CalendarSleepoverListSectionItem) {
    guard let reactor = self.reactor else { return }
    let popupViewController = iDormPopupViewController(viewType: .twoButton(
      contents: "외박 일정을 삭제하시겠습니까?",
      buttonTitle: "확인"
    ))
    popupViewController.modalPresentationStyle = .overFullScreen
    popupViewController.confirmButtonCompletion = {
      reactor.action.onNext(.itemSelected(item))
    }
    self.present(popupViewController, animated: false)
  }
}

// MARK: - CalendarScheduleHeaderDelegate

extension CalendarSleepoverListViewController: CalendarScheduleHeaderDelegate {
  func didTapRemoveCalendarButton() {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.didTapRemoveCalendarButton)
  }
}
