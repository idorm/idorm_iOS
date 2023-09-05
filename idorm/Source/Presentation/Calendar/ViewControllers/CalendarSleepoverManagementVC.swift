//
//  CalendarSleepoverManagementVC.swift
//  idorm
//
//  Created by 김응철 on 8/15/23.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class CalendarSleepoverManagementViewController: BaseViewController, View {
  
  typealias DataSource = UICollectionViewDiffableDataSource<Int, String>
  typealias Reactor = CalendarSleepoverManagementViewReactor
  
  // MARK: - UI Components
  
  /// `외박 일정`이 적혀있는 `UILabel`
  private let sleepoverCalendarLabel: UILabel = {
    let label = UILabel()
    label.text = "외박 일정"
    label.textColor = .black
    label.font = .iDormFont(.medium, size: 24.0)
    return label
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
    button.isSelected = true
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
    button.isSelected = false
    return button
  }()
  
  /// `시작` 버튼과 `종료` 버튼의 `ConfigurationUpdateHandler`
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
  
  /// `완료` 버튼
  private let doneButton: iDormButton = {
    let button = iDormButton("완료", image: nil)
    button.baseBackgroundColor = .iDormColor(.iDormBlue)
    button.baseForegroundColor = .white
    button.font = .iDormFont(.medium, size: 14.0)
    button.cornerRadius = 10.0
    return button
  }()
  
  /// 메인이 되는 `UICollectionView`
  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: layout
    )
    collectionView.delegate = self
    collectionView.isScrollEnabled = false
    collectionView.isPagingEnabled = false
    // Register
    collectionView.register(
      CalendarDateSelectionCell.self,
      forCellWithReuseIdentifier: CalendarDateSelectionCell.identifier
    )
    return collectionView
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
          ) as? CalendarDateSelectionCell
        else {
          return UICollectionViewCell()
        }
        cell.delegate = self
        cell.configure(.sleepover(date: item))
        return cell
      }
    )
    return dataSource
  }()
  
  /// 외박 일정 생성을 성공적으로 요청했을 때 불려지는 클로저입니다.
  var completion: (() -> Void)?
  
  // MARK: - Life Cycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    self.view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    [
      self.sleepoverCalendarLabel,
      self.startButton,
      self.endButton,
      self.collectionView,
      self.doneButton
    ].forEach{
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    self.sleepoverCalendarLabel.snp.makeConstraints { make in
      make.top.leading.equalTo(self.view.safeAreaLayoutGuide).inset(24.0)
    }
    
    self.startButton.snp.makeConstraints { make in
      make.leading.equalToSuperview()
      make.top.equalTo(self.sleepoverCalendarLabel.snp.bottom).offset(56.0)
      make.width.equalTo(self.view.frame.width / 2)
    }
    
    self.endButton.snp.makeConstraints { make in
      make.trailing.equalToSuperview()
      make.centerY.equalTo(self.startButton)
      make.width.equalTo(self.view.frame.width / 2)
    }
    
    self.collectionView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview()
      make.top.equalTo(self.startButton.snp.bottom).offset(16.0)
      make.height.equalTo(272.0)
    }
    
    self.doneButton.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview().inset(24.0)
      make.top.equalTo(self.collectionView.snp.bottom).offset(24.0)
      make.height.equalTo(50.0)
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: CalendarSleepoverManagementViewReactor) {
    // Action
    self.startButton.rx.tap
      .map { Reactor.Action.startButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.endButton.rx.tap
      .map { Reactor.Action.endButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.doneButton.rx.tap
      .map { Reactor.Action.doneButtonDidTap }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.map { $0.isStartDate }
      .skip(1)
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, isStartDate in
        let index = isStartDate ? 0 : 1
        owner.updateCollectionViewRect(index)
      }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.items }
      .take(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, items in
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        DispatchQueue.main.async {
          owner.dataSource.apply(snapshot)
        }
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$isPopping)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.navigationController?.popViewController(animated: true)
        owner.completion?()
      }
      .disposed(by: self.disposeBag)
  }
}

// MARK: - Privates

private extension CalendarSleepoverManagementViewController {
  /// `시작`, `종료`에 따른 `CollectionView`가 보여지는 `Rect`을 바꿔줍니다.
  /// 그리고 선택된 버튼에 대한 `isSelected`속성을 부여합니다.
  ///
  /// - Parameters:
  ///  - index: `시작`은 `0`, `종료`는 `1`
  func updateCollectionViewRect(_ index: Int) {
    let indexPath = IndexPath(item: index, section: 0)
    let rect = self.collectionView.layoutAttributesForItem(at: indexPath)?.frame
    self.collectionView.scrollRectToVisible(rect!, animated: true)
    self.startButton.isSelected = indexPath.item == 0 ? true : false
    self.endButton.isSelected = indexPath.item == 0 ? false : true
  }
}

extension CalendarSleepoverManagementViewController: CalendarDateSelectionCellDelegate {
  func calendarDidSelect(_ currentDateString: String) {
    guard let reactor = self.reactor else { return }
    reactor.action.onNext(.calendarDidSelect(date: currentDateString))
  }
}

// MARK: - UICollectionViewDelegate

extension CalendarSleepoverManagementViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    return CGSize(width: self.view.frame.width, height: 280.0)
  }
}
