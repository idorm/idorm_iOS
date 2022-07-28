//
//  CalendarChipTableViewCell.swift
//  idorm
//
//  Created by 김응철 on 2022/07/28.
//

import SnapKit
import UIKit

class CalendarChipTableViewCell: UITableViewCell {
  // MARK: - Properties
  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewCompositionalLayout(section: createChipLayout())
    let list = UICollectionView(frame: .zero, collectionViewLayout: layout)
    list.register(CalendarChipCollectionViewCell.self, forCellWithReuseIdentifier: CalendarChipCollectionViewCell.identifier)
    list.dataSource = self
    list.delegate = self
    
    return list
  }()
  
  static let identifier = "CalendarChipTableViewCell"
  
  // MARK: - Helpers
  func configureUI() {
    contentView.addSubview(collectionView)
    
    collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func createChipLayout() -> NSCollectionLayoutSection {
    let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .absolute(30))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .absolute(30))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 8
    section.orthogonalScrollingBehavior = .continuous
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24)
    
    return section
  }
}

extension CalendarChipTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let chipCell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarChipCollectionViewCell.identifier, for: indexPath) as? CalendarChipCollectionViewCell else { return UICollectionViewCell() }
    chipCell.configureUI()
    
    return chipCell
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 10
  }
}
