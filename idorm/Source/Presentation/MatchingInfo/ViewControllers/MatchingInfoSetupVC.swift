//
//  OnboardingViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/25.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa
import RxGesture
import ReactorKit

final class MatchingInfoSetupViewController: BaseViewController, View {
  
  typealias Reactor = MatchingInfoSetupViewReactor
  typealias DataSource = UICollectionViewDiffableDataSource
  <MatchingInfoSetupSection, MatchingInfoSetupSectionItem>
  
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
      MatchingInfoSetupAgeTextFieldCell.self,
      forCellWithReuseIdentifier: MatchingInfoSetupAgeTextFieldCell.identifier
    )
    collectionView.register(
      MatchingInfoSetupTextFieldCell.self,
      forCellWithReuseIdentifier: MatchingInfoSetupTextFieldCell.identifier
    )
    collectionView.register(
      MatchingInfoSetupTextViewCell.self,
      forCellWithReuseIdentifier: MatchingInfoSetupTextViewCell.identifier
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
    return view
  }()
  
  private var onboardingHeaderView: MatchingInfoSetupHeaderView?
  
  // MARK: - Properties
  
  private lazy var dataSource: DataSource = {
    let dataSource = DataSource(
      collectionView: self.collectionView,
      cellProvider: { collectionView, indexPath, item in
        guard let matchingInfo = self.reactor?.currentState.matchingInfo else { return .init() }
        switch item {
        case .dormitory, .gender, .period, .habit:
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MatchingInfoSetupButtonCell.identifier,
            for: indexPath
          ) as? MatchingInfoSetupButtonCell else {
            return UICollectionViewCell()
          }
          cell.configure(with: item)
          cell.buttonTappedHandler = { self.reactor?.action.onNext(.buttonDidChange($0)) }
          return cell
        case .age:
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MatchingInfoSetupAgeTextFieldCell.identifier,
            for: indexPath
          ) as? MatchingInfoSetupAgeTextFieldCell else {
            return UICollectionViewCell()
          }
          cell.configure(with: matchingInfo.age)
          cell.ageTextFieldHandler = { self.reactor?.action.onNext(.textDidChange(.age, $0)) }
          return cell
          
        case .wantToSay:
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MatchingInfoSetupTextViewCell.identifier,
            for: indexPath
          ) as? MatchingInfoSetupTextViewCell else {
            return UICollectionViewCell()
          }
          cell.configure(with: matchingInfo.wishText)
          cell.textViewHandler = {
            self.reactor?.action.onNext(.textDidChange(.wantToSay, $0))
            self.onboardingHeaderView?.updateCurrentLength($0)
          }
          return cell
          
        default: // 텍스트필드
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MatchingInfoSetupTextFieldCell.identifier,
            for: indexPath
          ) as? MatchingInfoSetupTextFieldCell else {
            return UICollectionViewCell()
          }
          switch item {
          case .wakeUpTime:
            cell.configure(item: .wakeUpTime, text: matchingInfo.wakeUpTime)
          case .arrangement:
            cell.configure(item: .arrangement, text: matchingInfo.cleanUpStatus)
          case .showerTime:
            cell.configure(item: .showerTime, text: matchingInfo.showerTime)
          case .kakao:
            cell.configure(item: .kakao, text: matchingInfo.openKakaoLink)
          case .mbti:
            cell.configure(item: .mbti, text: matchingInfo.mbti)
          default:
            fatalError("해당 아이템은 존재할 수 없습니다.")
          }
          cell.textFieldHandler = { item, text in
            self.reactor?.action.onNext(.textDidChange(item, text))
          }
          return cell
        }
      }
    )
    dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
      guard let section = self.dataSource.sectionIdentifier(for: indexPath.section)
      else { return UICollectionReusableView() }
      switch kind {
      case MatchingInfoSetupHeaderView.identifier:
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: MatchingInfoSetupHeaderView.identifier,
          for: indexPath
        ) as? MatchingInfoSetupHeaderView else {
          return UICollectionReusableView()
        }
        guard let matchingInfo = self.reactor?.currentState.matchingInfo else { return .init() }
        headerView.configure(with: section)
        headerView.updateCurrentLength(matchingInfo.wishText)
        if case .wantToSay = section {
          self.onboardingHeaderView = headerView
        }
        return headerView
        
      case MatchingInfoSetupFooterView.identifier:
        guard let footerView = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: MatchingInfoSetupFooterView.identifier,
          for: indexPath
        ) as? MatchingInfoSetupFooterView else {
          return UICollectionReusableView()
        }
        return footerView
      default:
        fatalError("❌ 알 수 없는 식별자입니다!")
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
    super.setupStyles()
    
    self.view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.collectionView,
      self.bottomMenuView
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.collectionView.snp.makeConstraints { make in
      make.top.directionalHorizontalEdges.equalTo(self.view.safeAreaLayoutGuide)
      make.bottom.equalTo(self.bottomMenuView.snp.top)
    }
    
    self.bottomMenuView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top)
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: MatchingInfoSetupViewReactor) {
    // Action
    
    self.collectionView.rx.tapGesture() { gesture, delegate in
      gesture.cancelsTouchesInView = false
      delegate.beginPolicy = .custom { [weak self] gesture in
        guard let self else { return false }
        if self.collectionView.indexPathForItem(
          at: gesture.location(in: self.collectionView)
        ) != nil {
          return false
        } else {
          return true
        }
      }
    }
    .when(.recognized)
    .asDriver(onErrorRecover: { _ in return .empty() })
    .drive(with: self) { owner, _ in
      owner.view.endEditing(true)
    }
    .disposed(by: self.disposeBag)
    
    self.bottomMenuView.leftButtonHandler = {
      reactor.action.onNext(.leftButtonDidTap)
    }
    
    self.bottomMenuView.rightButtonHandler = {
      reactor.action.onNext(.rightButtonDidTap)
    }
    
    // State
    
    reactor.state.map { $0.viewType }.take(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, viewType in
        switch viewType {
        case .signUp:
          owner.navigationItem.title = "내 정보 입력"
          owner.bottomMenuView.updateTitle(left: "정보 입력 건너 뛰기", right: "완료")
        case .theFirstTime:
          owner.navigationItem.title = "내 정보 입력"
          owner.bottomMenuView.updateTitle(left: "입력 초기화", right: "완료")
        case .correction:
          owner.navigationItem.title = "매칭 이미지 관리"
          owner.bottomMenuView.updateTitle(left: "입력 초기화", right: "완료")
        }
      }
      .disposed(by: self.disposeBag)
    
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
     
    reactor.pulse(\.$navigateToTabBarVC).skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        let tabBarVC = iDormTabBarViewController()
        owner.navigationController?.setViewControllers([tabBarVC], animated: true)
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$navigateToRootVC).skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.navigationController?.popToRootViewController(animated: true)
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$navigateToMatchingInfoCardVC).skip(1)
      .compactMap { $0 }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, matchingInfo in
        let viewController = MatchingInfoCardViewController(matchingInfo)
        viewController.reactor = MatchingInfoCardViewReactor(.signUp, matchingInfo: matchingInfo)
        owner.navigationController?.pushViewController(viewController, animated: true)
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$shouldReset).skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        var snapshot = owner.dataSource.snapshot()
        snapshot.reloadSections([
          .age(isFilterSetupVC: false), .wakeUpTime, .arrangement, .showerTime, .kakao, .mbti, .wantToSay
        ])
        owner.dataSource.apply(snapshot)
      }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { $0.isEnabledRightButton }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, isEnabled in
        owner.bottomMenuView.isEnabledRightButton = isEnabled
      }
      .disposed(by: self.disposeBag)
  }
}

// MARK: - Privates

private extension MatchingInfoSetupViewController {
  func getLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout { section, _ in
      guard let section = self.dataSource.sectionIdentifier(for: section) else {
        fatalError("❌ OnboardingSection을 발견하지 못했습니다!")
      }
      return section.section
    }
  }
}
