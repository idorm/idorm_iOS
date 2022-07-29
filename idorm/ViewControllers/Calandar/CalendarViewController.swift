//
//  CalandarViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/17.
//

import UIKit
import SnapKit
import FSCalendar

class CalendarViewController: UIViewController {
  // MARK: - Properties
  lazy var collectionView: UICollectionView = {
    let layout = createCompositionalLayout()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .white
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.register(CalendarChipCollectionViewCell.self, forCellWithReuseIdentifier: CalendarChipCollectionViewCell.identifier)
    collectionView.register(CalendarPersonalCollectionViewCell.self, forCellWithReuseIdentifier: CalendarPersonalCollectionViewCell.identifier)
    collectionView.register(CalendarDormCollectionViewCell.self, forCellWithReuseIdentifier: CalendarDormCollectionViewCell.identifier)
    collectionView.register(MainCalendarCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MainCalendarCollectionHeaderView.identifier)
    collectionView.register(PersonalCalendarCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PersonalCalendarCollectionHeaderView.identifier)
    collectionView.register(DormCalendarCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DormCalendarCollectionHeaderView.identifier)
    
    return collectionView
  }()
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.isHidden = true
  }
  
  // MARK: - Helpers
  private func configureUI() {
    navigationController?.navigationBar.isHidden = true
    view.backgroundColor = .white
    
    view.addSubview(collectionView)
  
    collectionView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
    let layout = UICollectionViewCompositionalLayout { [weak self] section, _ in
      switch section {
      case CalendarListType.chip.listIndex:
        return self?.createChipLayout()
      default:
        return self?.createBasicLayout()
      }
    }
    let config = UICollectionViewCompositionalLayoutConfiguration()
    config.interSectionSpacing = 26
    layout.configuration = config
    layout.register(CalendarRoundedBackgroundView.self, forDecorationViewOfKind: CalendarRoundedBackgroundView.reuseIdentifier)
    return layout
  }
  
  private func createChipLayout() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .absolute(30))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .absolute(30))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let headerSize = NSCollectionLayoutSize(widthDimension: .absolute(view.frame.width), heightDimension: .absolute(300))
    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
    
    let section = NSCollectionLayoutSection(group: group)
    section.boundarySupplementaryItems = [header]
    section.orthogonalScrollingBehavior = .continuous
    section.interGroupSpacing = 8
    section.supplementariesFollowContentInsets = false
    section.contentInsets = NSDirectionalEdgeInsets(top: 17, leading: 24, bottom: 0, trailing: 24)
    
    return section
  }
  
  private func createBasicLayout() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(view.frame.width - 48), heightDimension: .absolute(36))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(view.frame.width - 48), heightDimension: .absolute(36))
    let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
    
    let headerSize = NSCollectionLayoutSize(widthDimension: .absolute(view.frame.width - 48), heightDimension: .absolute(50))
    let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
    
    let section = NSCollectionLayoutSection(group: group)
    section.boundarySupplementaryItems = [header]
    section.interGroupSpacing = 10
    section.decorationItems = [NSCollectionLayoutDecorationItem.background(elementKind: CalendarRoundedBackgroundView.reuseIdentifier) ]
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 16, trailing: 24)
    
    return section
  }
}

extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch indexPath.section {
    case CalendarListType.chip.listIndex:
      guard let chipCell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarChipCollectionViewCell.identifier, for: indexPath) as? CalendarChipCollectionViewCell else { return UICollectionViewCell() }
      chipCell.configureUI()
      return chipCell
    case CalendarListType.personal.listIndex:
      guard let personalCell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarPersonalCollectionViewCell.identifier, for: indexPath) as? CalendarPersonalCollectionViewCell else { return UICollectionViewCell() }
      personalCell.configureUI()
      return personalCell
    case CalendarListType.dorm.listIndex:
      guard let dormCell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDormCollectionViewCell.identifier, for: indexPath) as? CalendarDormCollectionViewCell else { return UICollectionViewCell() }
      dormCell.configureUI()
      return dormCell
    default:
      return UICollectionViewCell()
    }
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return CalendarListType.allCases.count
  }
    
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 10
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    switch indexPath.section {
    case CalendarListType.chip.listIndex:
      guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: MainCalendarCollectionHeaderView.identifier, for: indexPath) as? MainCalendarCollectionHeaderView else { return UICollectionReusableView() }
      header.configureUI()
      return header
    case CalendarListType.personal.listIndex:
      guard let personalHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PersonalCalendarCollectionHeaderView.identifier, for: indexPath) as? PersonalCalendarCollectionHeaderView else { return UICollectionReusableView() }
      personalHeader.configureUI()
      return personalHeader
    case CalendarListType.dorm.listIndex:
      guard let dormHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DormCalendarCollectionHeaderView.identifier, for: indexPath) as? DormCalendarCollectionHeaderView else { return UICollectionReusableView() }
      dormHeader.configureUI()
      return dormHeader
    default:
      return UICollectionReusableView()
    }
  }
}
