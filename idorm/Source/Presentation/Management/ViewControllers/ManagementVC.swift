//
//  BaseManagementViewController.swift
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

final class ManagementViewController: BaseViewController, View {
  
  typealias DataSource = UICollectionViewDiffableDataSource<ManagementSection, ManagementSectionItem>
  typealias Reactor = ManagementViewReactor
  
  // MARK: - UI Components
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: self.getLayout()
    )
    collectionView.backgroundColor = .iDormColor(.iDormGray100)
    // Cell
    collectionView.register(cellType: CommunityPostListCell.self)
    collectionView.register(cellType: CommunityCommentCell.self)
    collectionView.register(cellType: ManagementMatchingCardCell.self)
    return collectionView
  }()
  
  private lazy var orderView: ManagementOrderView = {
    let view = ManagementOrderView()
    view.buttonHandler = { self.reactor?.action.onNext(.orderButtonDidTap(isLastest: $0)) }
    return view
  }()
  
  // MARK: - Properties
  
  private lazy var dataSource: DataSource = {
    let dataSource = DataSource(
      collectionView: self.collectionView,
      cellProvider: { collectionView, indexPath, item in
        switch item {
        case .post(let post):
          let cell = collectionView.dequeueReusableCell(for: indexPath) as CommunityPostListCell
          cell.configure(with: post)
          return cell
        case .comment(let comment):
          let cell = collectionView.dequeueReusableCell(for: indexPath) as CommunityCommentCell
          cell.configure(with: comment)
          return cell
        case .matchingCard(let matchingInfo):
          let cell = collectionView.dequeueReusableCell(for: indexPath) as ManagementMatchingCardCell
          cell.configure(with: matchingInfo)
          return cell
        }
      }
    )
    return dataSource
  }()
  
  // MARK: - Setup

  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.orderView,
      self.collectionView
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.orderView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview()
      make.top.equalTo(self.view.safeAreaLayoutGuide)
      make.height.equalTo(53.0)
    }
    
    self.collectionView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.bottom.equalTo(self.view.safeAreaLayoutGuide)
      make.top.equalTo(self.orderView.snp.bottom)
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: ManagementViewReactor) {
    
    // Action
    
    
    
    // State
    
    reactor.state.map { $0.viewType }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, viewType in
        owner.navigationItem.title = viewType.title
      }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { (section: $0.section, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, sectionData in
        var snapshot = NSDiffableDataSourceSnapshot<ManagementSection, ManagementSectionItem>()
        snapshot.appendSections([sectionData.section])
        snapshot.appendItems(sectionData.items)
        DispatchQueue.main.async {
          owner.dataSource.apply(snapshot)
        }
      }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.isLastest }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, isLastest in
        owner.orderView.toggleButton(isLastest: isLastest)
      }
      .disposed(by: self.disposeBag)
  }
}

// MARK: - Privates

private extension ManagementViewController {
  func getLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout { [weak self] index, _ in
      guard let section = self?.dataSource.sectionIdentifier(for: index) else {
        fatalError("❌ ManagementSection을 발견하지 못했습니다!")
      }
      return section.section
    }
  }
}
