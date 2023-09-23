//
//  MatchingInfoCardViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/25.
//

import UIKit

import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

/// 매칭 정보 카드만을 보여주는 페이지
final class MatchingInfoCardViewController: BaseViewController, View {
  
  typealias Reactor = MatchingInfoCardViewReactor
  
  // MARK: - UI Components
  
  /// 하단에 있는 `BottomMenuView`
  private lazy var bottomMenuView: iDormBottomMenuView = {
    let view = iDormBottomMenuView()
    view.rightButtonHandler = { self.reactor?.action.onNext(.rightButtonDidTap) }
    view.leftButtonHandler = { self.reactor?.action.onNext(.leftButtonDidTap) }
    return view
  }()
  
  /// 메인이 되는 `iDormMatchingCardView`
  private lazy var matchingCardView = iDormMatchingCardView(self.matchingInfo)
  
  // MARK: - Properties
  
  private let matchingInfo: MatchingInfo
  
  // MARK: - LifeCycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  // MARK: - Initializer
  
  init(_ matchingInfo: MatchingInfo) {
    self.matchingInfo = matchingInfo
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    
    self.view.backgroundColor = .white
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    
    [
      self.matchingCardView,
      self.bottomMenuView
    ].forEach {
      self.view.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.bottomMenuView.snp.makeConstraints { make in
      make.directionalHorizontalEdges.equalToSuperview()
      make.bottom.equalTo(self.view.safeAreaLayoutGuide)
    }
    
    self.matchingCardView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalTo(self.view.safeAreaLayoutGuide).offset(-65.0)
    }
  }
  
  // MARK: - Bind
  
  func bind(reactor: MatchingInfoCardViewReactor) {
    
    // State
    
    reactor.state.map { $0.viewType }.take(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, viewType in
        switch viewType {
        case .signUp:
          owner.navigationItem.title = "내 프로필 이미지"
          owner.bottomMenuView.updateTitle(left: "뒤로 가기", right: "완료")
        case .theFirstTime:
          owner.navigationItem.title = "매칭 이미지 관리"
          owner.bottomMenuView.updateTitle(left: "뒤로 가기", right: "완료")
        case .correction:
          owner.navigationItem.title = "매칭 이미지 관리"
          owner.bottomMenuView.updateTitle(left: "정보 수정", right: "완료")
        }
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$isPopping).skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        owner.navigationController?.popViewController(animated: true)
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$naviagetToTabBarVC).skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, _ in
        let tabBarVC = TabBarViewController()
        owner.navigationController?.setViewControllers([tabBarVC], animated: true)
      }
      .disposed(by: self.disposeBag)
    
    reactor.pulse(\.$navigateToOnboardingVC).skip(1)
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, viewType in
        let viewController = MatchingInfoSetupViewController()
        let reactor = MatchingInfoSetupViewReactor(viewType)
        viewController.reactor = reactor
        owner.navigationController?.pushViewController(viewController, animated: true)
      }
      .disposed(by: self.disposeBag)
  }
}
