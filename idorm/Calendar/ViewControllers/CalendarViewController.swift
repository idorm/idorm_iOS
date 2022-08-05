//
//  CalandarViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/07/17.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class CalendarViewController: UIViewController {
  // MARK: - Properties
  lazy var collectionView: UICollectionView = {
    let layout = createCompositionalLayout()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .white
    collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 29, right: 0)
    collectionView.bounces = false
    collectionView.delegate = self
    collectionView.isScrollEnabled = false
    collectionView.dataSource = self
    collectionView.register(CalendarChipCell.self, forCellWithReuseIdentifier: CalendarChipCell.identifier)
    collectionView.register(CalendarPersonalCell.self, forCellWithReuseIdentifier: CalendarPersonalCell.identifier)
    collectionView.register(CalendarDormCell.self, forCellWithReuseIdentifier: CalendarDormCell.identifier)
//    collectionView.register(CalendarView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CalendarView.identifier)
    collectionView.register(CalendarPersonalCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CalendarPersonalCollectionHeaderView.identifier)
    collectionView.register(CalendarDormCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CalendarDormCollectionHeaderView.identifier)
    
    return collectionView
  }()
  
  lazy var topView: UIView = {
    let view = UIView()
    view.backgroundColor = .idorm_gray_100
    
    return view
  }()
  
  lazy var calendarView: CalendarView = {
    let view = CalendarView(type: .main)
    
    return view
  }()
  
  lazy var scrollView: UIScrollView = {
    let sv = UIScrollView()
    sv.backgroundColor = .white
    sv.bounces = false
    sv.showsVerticalScrollIndicator = false
    
    return sv
  }()
  
  lazy var contentView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    
    return view
  }()

  let disposeBag = DisposeBag()
  let viewModel = CalendarViewModel()

  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bind()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.isHidden = true
  }
  
  // MARK: - Bind
  private func bind() {
    viewModel.output.onChangedCalendarViewHeight
      .bind(onNext: { [weak self] _ in
        self?.updateContentViewSize()
      })
      .disposed(by: disposeBag)
    
    collectionView.rx.didEndDisplayingCell
      .bind(onNext: { [weak self] _ in
        self?.updateContentViewSize()
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  private func updateContentViewSize() {
    let height = calendarView.frame.height + collectionView.collectionViewLayout.collectionViewContentSize.height
    contentView.snp.updateConstraints { make in
      make.height.equalTo(height)
    }
  }
  
  private func configureUI() {
    navigationController?.navigationBar.isHidden = true
    view.backgroundColor = .white
    
    [ topView, scrollView ]
      .forEach { view.addSubview($0) }
    
    topView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.bottom.equalTo(scrollView.snp.top)
    }
    
    scrollView.snp.makeConstraints { make in
      make.edges.equalTo(view.safeAreaLayoutGuide)
    }
    
    scrollView.addSubview(contentView)
    
    contentView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview().inset(16)
      make.width.equalTo(view.frame.width)
      make.height.equalTo(1000)
    }
    
    [ calendarView, collectionView ]
      .forEach { contentView.addSubview($0) }
    
    calendarView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
    }
    
    collectionView.snp.makeConstraints { make in
      make.top.equalTo(calendarView.snp.bottom)
      make.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }
}

/// - Compositional Layout
extension CalendarViewController {
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
    let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .estimated(30))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .estimated(30))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .continuous
    section.interGroupSpacing = 8
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
    section.boundarySupplementaryItems = [ header ]
    section.interGroupSpacing = 10
    section.decorationItems = [NSCollectionLayoutDecorationItem.background(elementKind: CalendarRoundedBackgroundView.reuseIdentifier) ]
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 16, trailing: 24)
    
    return section
  }
}

/// DataSource, Delegate
extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch indexPath.section {
    case CalendarListType.chip.listIndex:
      guard let chipCell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarChipCell.identifier, for: indexPath) as? CalendarChipCell else { return UICollectionViewCell() }
      chipCell.configureUI()
      if indexPath.row == 0 {
        chipCell.contentView.layer.opacity = 1
        chipCell.leftDayLabel.textColor = .idorm_blue
      }
      return chipCell
    case CalendarListType.personal.listIndex:
      guard let personalCell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarPersonalCell.identifier, for: indexPath) as? CalendarPersonalCell else { return UICollectionViewCell() }
      personalCell.configureUI()
      return personalCell
    case CalendarListType.dorm.listIndex:
      guard let dormCell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDormCell.identifier, for: indexPath) as? CalendarDormCell else { return UICollectionViewCell() }
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
    return 2
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    switch indexPath.section {
    case CalendarListType.personal.listIndex:
      guard let personalHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CalendarPersonalCollectionHeaderView.identifier, for: indexPath) as? CalendarPersonalCollectionHeaderView else { return UICollectionReusableView() }
      personalHeader.configureUI()
      return personalHeader
    case CalendarListType.dorm.listIndex:
      guard let dormHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CalendarDormCollectionHeaderView.identifier, for: indexPath) as? CalendarDormCollectionHeaderView else { return UICollectionReusableView() }
      dormHeader.configureUI()
      return dormHeader
    default:
      return UICollectionReusableView()
    }
  }
}
