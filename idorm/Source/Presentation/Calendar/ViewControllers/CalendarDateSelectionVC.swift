//
//  CalendarDateSelectionVC.swift
//  idorm
//
//  Created by 김응철 on 8/3/23.
//

import UIKit

import RxSwift
import RxCocoa
import ReactorKit
import PanModal
import SnapKit

protocol CalendarDateSelectionViewControllerDelegate: AnyObject {
  func dateDidChange(startDate: String, startTime: String, endDate: String, endTime: String)
}

/// 자세한 일정 날짜와 시간을 선택할 수 있는 `ViewController`
final class CalendarDateSelectionViewController: BaseViewController, View {
  
  typealias DataSource = UICollectionViewDiffableDataSource<Int, [String]>
  typealias Reactor = CalendarDateSelectionViewReactor
  
  // MARK: - UI Components
  
  /// 메인이 되는 `UICollectionView`
  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.itemSize = CGSize(width: self.view.frame.width, height: 452.0)
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: layout
    )
    collectionView.isScrollEnabled = false
    collectionView.isPagingEnabled = false 
    // Register
    collectionView.register(
      CalendarDateSelectionCell.self,
      forCellWithReuseIdentifier: CalendarDateSelectionCell.identifier
    )
    return collectionView
  }()
  
  /// `시작` 버튼
  private lazy var startButton: iDormButton = {
    let button = iDormButton("시작", image: nil)
    button.font = .iDormFont(.medium, size: 14.0)
    button.baseForegroundColor = .black
    button.baseBackgroundColor = .clear
    button.isHiddenBottomBorderLine = false
    button.edgeInsets = .init(top: 0, leading: 0, bottom: 20, trailing: 0)
    button.configurationUpdateHandler = self.buttonUpdateHandler
    return button
  }()
  
  /// `종료` 버튼
  private lazy var endButton: iDormButton = {
    let button = iDormButton("종료", image: nil)
    button.font = .iDormFont(.medium, size: 14.0)
    button.baseForegroundColor = .black
    button.baseBackgroundColor = .clear
    button.isHiddenBottomBorderLine = false
    button.edgeInsets = .init(top: 0, leading: 0, bottom: 20, trailing: 0)
    button.configurationUpdateHandler = self.buttonUpdateHandler
    return button
  }()
  
  /// `완료` 버튼
  private let doneButton: iDormButton = {
    let button = iDormButton("완료", image: nil)
    button.baseBackgroundColor = .iDormColor(.iDormBlue)
    button.baseForegroundColor = .white
    button.font = .iDormFont(.medium, size: 14.0)
    button.cornerRadius = 10.0
    
    return button
  }()
  
  /// 상단에 있는 회색 라인의 `UIView`
  private let customIndicator: UIView = {
    let view = UIView()
    view.backgroundColor = .iDormColor(.iDormGray300)
    view.layer.cornerRadius = 2.0
    return view
  }()
  
  private let buttonUpdateHandler: UIButton.ConfigurationUpdateHandler = {
    let handler: UIButton.ConfigurationUpdateHandler = { button in
      switch button.state {
      case .selected:
        button.configuration?.baseForegroundColor = .black
      case .normal:
        button.configuration?.baseForegroundColor = .iDormColor(.iDormGray200)
      default:
        break
      }
    }
    return handler
  }()
  
  // MARK: - Properties
  
  private lazy var dataSource: DataSource = {
    let dataSource = DataSource(
      collectionView: self.collectionView,
      cellProvider: { collectionView, indexPath, item in
        guard
          let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: CalendarDateSelectionCell.identifier,
          for: indexPath
          ) as? CalendarDateSelectionCell,
          let date = item.first,
          let time = item.last
        else {
          return UICollectionViewCell()
        }
        print(item)
        cell.updateUI(date: date, time: time)
        return cell
      }
    )
    return dataSource
  }()
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.customIndicator,
      self.startButton,
      self.endButton,
      self.collectionView,
      self.doneButton
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.customIndicator.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(10.0)
      make.width.equalTo(86.0)
      make.height.equalTo(3.0)
    }
    
    self.startButton.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.top.equalToSuperview().inset(43.0)
      make.width.equalTo(self.view.frame.width / 2)
      make.height.equalTo(41.0)
    }
    
    self.endButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview()
      make.top.equalToSuperview().inset(43.0)
      make.width.equalTo(self.view.frame.width / 2)
      make.height.equalTo(41.0)
    }
    
    self.collectionView.snp.makeConstraints { make in
      make.top.equalTo(self.startButton.snp.bottom)
      make.height.equalTo(452.0)
      make.directionalHorizontalEdges.equalToSuperview()
    }
    
    self.doneButton.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
      make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(20.0)
      make.height.equalTo(53.0)
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: CalendarDateSelectionViewReactor) {
    // Action
    Observable.merge(
      self.rx.viewWillAppear,
      self.rx.viewDidAppear
    )
      .map { _ in Reactor.Action.viewDidAppear }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.startButton.rx.tap
      .map { Reactor.Action.tabButtonDidTap(isStartDate: true) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.endButton.rx.tap
      .map { Reactor.Action.tabButtonDidTap(isStartDate: false) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { $0.scrollCollectionView }
      .skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, indexPath in
        owner.updateCollectionViewRect(indexPath)
      }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.items }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, items in
        var snapshot = NSDiffableDataSourceSnapshot<Int, [String]>()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        DispatchQueue.main.async {
          owner.dataSource.applySnapshotUsingReloadData(snapshot)
        }
      }
      .disposed(by: self.disposeBag)
  }
}

// MARK: - Privates

private extension CalendarDateSelectionViewController {
  /// `시작`, `종료`에 따른 `CollectionView`가 보여지는 `Rect`을 바꿔줍니다.
  /// 그리고 선택된 버튼에 대한 `isSelected`속성을 부여합니다.
  ///
  /// - Parameters:
  ///  - isStartDate: `시작` 버튼이 선택되어 있는지에 대한 여부
  func updateCollectionViewRect(_ indexPath: Int) {
    let indexPath = IndexPath(item: indexPath, section: 0)
    let rect = self.collectionView.layoutAttributesForItem(at: indexPath)?.frame
    self.collectionView.scrollRectToVisible(rect!, animated: true)
    self.startButton.isSelected = indexPath.item == 0 ? true : false
    self.endButton.isSelected = indexPath.item == 0 ? false : true
  }
}

// MARK: - PanModal

extension CalendarDateSelectionViewController: PanModalPresentable {
  var panScrollable: UIScrollView? { nil }
  
  var showDragIndicator: Bool { false }
  
  var longFormHeight: PanModalHeight { .contentHeight(609.0) }
  
  var shortFormHeight: PanModalHeight { .contentHeight(609.0) }

  var cornerRadius: CGFloat { 15.5 }
}

// MARK: - CalendarDateSelectionCellDelegate

extension CalendarDateSelectionViewController: CalendarDateSelectionCellDelegate {
  func calendarDidSelect(_ currentDateString: String) {
    self.reactor?.action.onNext(.calendarDidSelect(currentDateString))
  }
  
  func pickerViewDidChangeRow(_ currentTimeString: String) {
    self.reactor?.action.onNext(.pickerViewDidChangeRow(currentTimeString))
  }
}
