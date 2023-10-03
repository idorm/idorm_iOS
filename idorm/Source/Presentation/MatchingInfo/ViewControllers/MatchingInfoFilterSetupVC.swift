//
//  MatchingFilterSetupVC.swift
//  idorm
//
//  Created by 김응철 on 9/25/23.
//

import UIKit

import SnapKit
import ReactorKit
import RxSwift
import RxCocoa

final class MatchingInfoFilterSetupViewController: BaseViewController, View {
  
  typealias Reactor = MatchingInfoFilterSetupViewReactor
  typealias DataSource = UICollectionViewDiffableDataSource<MatchingInfoSetupSection, MatchingInfoSetupSectionItem>
  
  // MARK: - UI Components
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: self.getLayout()
    )
    collectionView.keyboardDismissMode = .interactive
    // Cell
    collectionView.register(
      MatchingInfoSetupButtonCell.self,
      forCellWithReuseIdentifier: MatchingInfoSetupButtonCell.identifier
    )
    collectionView.register(
      MatchingInfoSetupSliderCell.self,
      forCellWithReuseIdentifier: MatchingInfoSetupSliderCell.identifier
    )
    // ReusableView
    collectionView.register(
      MatchingInfoSetupHeaderView.self,
      forSupplementaryViewOfKind: MatchingInfoSetupHeaderView.identifier,
      withReuseIdentifier: MatchingInfoSetupHeaderView.identifier
    )
    collectionView.register(
      MatchingInfoSetupFooterView.self,
      forSupplementaryViewOfKind: MatchingInfoSetupFooterView.identifier,
      withReuseIdentifier: MatchingInfoSetupFooterView.identifier
    )
    return collectionView
  }()
  
  private lazy var bottomMenuView: iDormBottomMenuView = {
    let view = iDormBottomMenuView()
    view.updateTitle(left: "선택 초기화", right: "필터링 완료")
    view.leftButtonHandler = { self.reactor?.action.onNext(.resetButtonDidTap) }
    view.rightButtonHandler = { self.reactor?.action.onNext(.confirmButtonDidTap) }
    return view
  }()
  
  // MARK: - Properties
  
  private lazy var dataSource: DataSource = {
    let dataSource = DataSource(
      collectionView: self.collectionView,
      cellProvider: { collectionView, indexPath, item in
        switch item {
        case .age:
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MatchingInfoSetupSliderCell.identifier,
            for: indexPath
          ) as? MatchingInfoSetupSliderCell else {
            return UICollectionViewCell()
          }
          let matchingInfoFilter = UserStorage.shared.matchingMateFilter
          cell.configure(
            minAge: matchingInfoFilter.value?.minAge ?? 20,
            maxAge: matchingInfoFilter.value?.maxAge ?? 30
          )
          cell.sliderHandler = {
            self.reactor?.action.onNext(.sliderDidChange(minValue: $0, maxValue: $1))
          }
          return cell
        default:
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MatchingInfoSetupButtonCell.identifier,
            for: indexPath
          ) as? MatchingInfoSetupButtonCell else {
            return UICollectionViewCell()
          }
          cell.buttonTappedHandler = {
            self.reactor?.action.onNext(.buttonDidTap($0))
          }
          cell.configure(with: item)
          return cell
        }
      })
    dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
      guard let section = dataSource.sectionIdentifier(for: indexPath.section) else {
        fatalError("❌ MatchingInfoSetupSection 섹션이 존재하지 않습니다.")
      }
      switch kind {
      case MatchingInfoSetupHeaderView.identifier:
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
          ofKind: MatchingInfoSetupHeaderView.identifier,
          withReuseIdentifier: MatchingInfoSetupHeaderView.identifier,
          for: indexPath
        ) as? MatchingInfoSetupHeaderView else {
          return UICollectionReusableView()
        }
        headerView.configure(with: section)
        return headerView
      case MatchingInfoSetupFooterView.identifier:
        guard let footerView = collectionView.dequeueReusableSupplementaryView(
          ofKind: MatchingInfoSetupFooterView.identifier,
          withReuseIdentifier: MatchingInfoSetupFooterView.identifier,
          for: indexPath
        ) as? MatchingInfoSetupFooterView else {
          return UICollectionReusableView()
        }
        return footerView
      default:
        return UICollectionReusableView()
      }
    }
    return dataSource
  }()
  
  // MARK: - Life Cycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.navigationController?.title = "필터"
  }
  
  override func setupLayouts() {
    [
      self.collectionView,
      self.bottomMenuView
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.bottomMenuView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.bottom.equalTo(self.view.safeAreaLayoutGuide)
    }
    
    self.collectionView.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalTo(self.bottomMenuView.snp.top)
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: MatchingInfoFilterSetupViewReactor) {
    // Action
    
    // State
    
    reactor.state.map { (sections: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, sectionData in
        var snapshot = NSDiffableDataSourceSnapshot<MatchingInfoSetupSection, MatchingInfoSetupSectionItem>()
        snapshot.appendSections(sectionData.sections)
        sectionData.items.enumerated().forEach { index, items in
          snapshot.appendItems(items, toSection: sectionData.sections[index])
        }
        DispatchQueue.main.async {
          owner.dataSource.apply(snapshot)
        }
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$isPopping).skip(1)
      .asDriver(onErrorRecover: { _ in return .empty()} )
      .drive(with: self) { owner, _ in
        owner.navigationController?.popViewController(animated: true)
      }
      .disposed(by: self.disposeBag)
  }
}

// MARK: - Privates

private extension MatchingInfoFilterSetupViewController {
  func getLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout { section, _ in
      guard let section = self.dataSource.sectionIdentifier(for: section) else {
        fatalError("❌ MatchingInfoSetupSection을 찾을 수 없습니다!")
      }
      return section.section
    }
  }
}
