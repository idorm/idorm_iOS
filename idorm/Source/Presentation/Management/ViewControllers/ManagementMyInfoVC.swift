//
//  ManagementMyInfoVC.swift
//  idorm
//
//  Created by 김응철 on 9/29/23.
//

import UIKit

import SnapKit
import ReactorKit
import RxSwift
import RxCocoa
import Reusable

final class ManagementMyInfoViewController: BaseViewController, View {
  
  typealias DataSource = UICollectionViewDiffableDataSource<ManagementMyInfoSection, ManagementMyInfoSectionItem>
  typealias Reactor = ManagementMyInfoViewReactor
    
  // MARK: - UI Components
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: self.getLayout()
    )
    collectionView.register(cellType: ManagementMyInfoCell.self)
    collectionView.register(cellType: ManagementMyInfoProfileCell.self)
    collectionView.register(cellType: ManagementMyInfoMembershipCell.self)
    collectionView.register(
      supplementaryViewType: ManagementMyInfoFooterView.self,
      ofKind: ManagementMyInfoFooterView.reuseIdentifier
    )
    return collectionView
  }()
  
  // MARK: - Properties
  
  private lazy var dataSource: DataSource = {
    let dataSource = DataSource(
      collectionView: self.collectionView,
      cellProvider: { collectionView, indexPath, item in
        switch item {
        case .profileImage(let imageURL):
          let cell = collectionView.dequeueReusableCell(for: indexPath) as ManagementMyInfoProfileCell
          cell.configure(with: imageURL)
          return cell
        case .membership:
          let cell = collectionView.dequeueReusableCell(for: indexPath) as ManagementMyInfoMembershipCell
          return cell
        default:
          let cell = collectionView.dequeueReusableCell(for: indexPath) as ManagementMyInfoCell
          cell.configure(with: item)
          return cell
        }
      }
    )
    dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
      switch kind {
      case ManagementMyInfoFooterView.reuseIdentifier:
        let footerView = collectionView.dequeueReusableSupplementaryView(
          ofKind: ManagementMyInfoFooterView.reuseIdentifier,
          for: indexPath
        ) as ManagementMyInfoFooterView
        return footerView
      default:
        return UICollectionReusableView()
      }
    }
    return dataSource
  }()
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.navigationItem.title = "내 정보 관리"
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
  
  func bind(reactor: ManagementMyInfoViewReactor) {
    
    // Action
    
    
    // State
    
    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, sectionData in
        var snapshot = NSDiffableDataSourceSnapshot<ManagementMyInfoSection, ManagementMyInfoSectionItem>()
        snapshot.appendSections(sectionData.sections)
        sectionData.items.enumerated().forEach { index, items in
          snapshot.appendItems(items, toSection: sectionData.sections[index])
        }
        DispatchQueue.main.async {
          owner.dataSource.apply(snapshot)
        }
      }
      .disposed(by: self.disposeBag)
  }
}

// MARK: - Privates

private extension ManagementMyInfoViewController {
  func getLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout { [weak self] index, _ in
      guard let section = self?.dataSource.sectionIdentifier(for: index) else {
        fatalError("❌ ManagementMyInfoSection을 찾을 수 없습니다!")
      }
      return section.section
    }
  }
}
