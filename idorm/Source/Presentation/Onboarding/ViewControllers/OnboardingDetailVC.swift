//
//  OnboardingDetailViewController.swift
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

final class OnboardingDetailViewController: BaseViewController, View {
  
  typealias Reactor = OnboardingDetailViewReactor

  // MARK: - Properties
  
  private let indicator = UIActivityIndicatorView().then {
    $0.color = .gray
  }

  private var floatyBottomView: FloatyBottomView!
  private lazy var matchingCard = MatchingCard(member)

  private let member: MatchingDTO.Retrieve
  private let type: OnboardingEnumerations
  private let reactor: OnboardingDetailViewReactor
  
  // MARK: - LifeCycle
  
  init(_ member: MatchingDTO.Retrieve, type: OnboardingEnumerations) {
    self.type = type
    self.member = member
    self.reactor = OnboardingDetailViewReactor(type)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    setupFloatyBottomView()
    super.viewDidLoad()
  }
  
  // MARK: - Bind
  
  func bind(reactor: OnboardingDetailViewReactor) {
    
    // MARK: - Action
    
    // FloatyBottomView 왼쪽버튼 클릭
    floatyBottomView.leftButton.rx.tap
      .map { OnboardingDetailViewReactor.Action.didTapLeftButton }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // FloatyBottomView 오른쪽버튼 클릭
    floatyBottomView.rightButton.rx.tap
      .withUnretained(self)
      .map { OnboardingDetailViewReactor.Action.didTapRightButton($0.0.member) }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // MARK: - State
    
    // 인디케이터 애니메이션
    reactor.state
      .map { $0.isLoading }
      .bind(to: indicator.rx.isAnimating)
      .disposed(by: disposeBag)
    
    // PopVC
    reactor.state
      .map { $0.popVC }
      .filter { $0 }
      .withUnretained(self)
      .bind { $0.0.navigationController?.popViewController(animated: true) }
      .disposed(by: disposeBag)
    
    // OnboardingVC로 이동
    reactor.state
      .map { $0.isOpenedOnboardingVC }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let onboardingVC = OnboardingViewController(owner.type)
        owner.navigationController?.pushViewController(onboardingVC, animated: true)
      }
      .disposed(by: disposeBag)
    
    // MainVC로 이동
    reactor.state
      .map { $0.isOpenedMainVC }
      .filter { $0 }
      .withUnretained(self)
      .bind { owner, _ in
        let mainVC = TabBarController()
        mainVC.modalPresentationStyle = .fullScreen
        owner.present(mainVC, animated: true)
      }
      .disposed(by: disposeBag)
  }

  // MARK: - Setup
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .white
    navigationItem.title = "내 프로필 이미지"
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [floatyBottomView, matchingCard, indicator]
      .forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()

    floatyBottomView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
      make.height.equalTo(76)
    }

    matchingCard.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(24)
      make.centerY.equalTo(view.safeAreaLayoutGuide).offset(-50)
      make.height.equalTo(431)
    }

    indicator.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(20)
    }
  }
  
  private func setupFloatyBottomView() {
    switch type {
    case .modify:
      self.floatyBottomView = FloatyBottomView(.correction)
    case .main, .initial:
      self.floatyBottomView = FloatyBottomView(.back)
    }
  }
}
