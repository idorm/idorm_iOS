//
//  MatchingFilterSetupVC.swift
//  idorm
//
//  Created by 김응철 on 9/25/23.
//

import UIKit

import SnapKit
import ReactorKit

final class MatchingInfoFilterSetupViewController: BaseViewController, View {
  
  typealias Reactor = MatchingInfoFilterSetupViewReactor
  
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
  
  // MARK: - Setup
  
  override func setupStyles() {}
  
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
  }
}

// MARK: - Privates

private extension MatchingInfoFilterSetupViewController {
  func getLayout() -> UICollectionViewCompositionalLayout {
    
  }
}
