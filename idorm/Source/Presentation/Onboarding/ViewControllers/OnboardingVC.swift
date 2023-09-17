//
//  OnboardingViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/12/25.
//

import UIKit

import SnapKit
import Then
import AEOTPTextField
import RSKGrowingTextView
import RxSwift
import RxCocoa
import RxGesture
import RxAppState
import ReactorKit
import RxOptional

final class OnboardingViewController: BaseViewController, View {
  
  typealias Reactor = OnboardingViewReactor2
  typealias DataSource = UICollectionViewDiffableDataSource
  <OnboardingSection, OnboardingSectionItem>
  
  // MARK: - UI Components
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: self.getLayout()
    )
    collectionView.keyboardDismissMode = .interactive
    // Cell
    collectionView.register(
      OnboardingButtonCell.self,
      forCellWithReuseIdentifier: OnboardingButtonCell.identifier
    )
    collectionView.register(
      OnboardingAgeCell.self,
      forCellWithReuseIdentifier: OnboardingAgeCell.identifier
    )
    collectionView.register(
      OnboardingTextFieldCell.self,
      forCellWithReuseIdentifier: OnboardingTextFieldCell.identifier
    )
    collectionView.register(
      OnboardingTextViewCell.self,
      forCellWithReuseIdentifier: OnboardingTextViewCell.identifier
    )
    // ReusableView
    collectionView.register(
      OnboardingHeaderView.self,
      forSupplementaryViewOfKind: OnboardingHeaderView.identifier,
      withReuseIdentifier: OnboardingHeaderView.identifier
    )
    collectionView.register(
      OnboardingFooterView.self,
      forSupplementaryViewOfKind: OnboardingFooterView.identifier,
      withReuseIdentifier: OnboardingFooterView.identifier
    )
    return collectionView
  }()
  
  private lazy var bottomMenuView: iDormBottomMenuView = {
    let view = iDormBottomMenuView()
    return view
  }()
  
  private var onboardingHeaderView: OnboardingHeaderView?
  
  // MARK: - Properties
  
  private lazy var dataSource: DataSource = {
    let dataSource = DataSource(
      collectionView: self.collectionView,
      cellProvider: { collectionView, indexPath, item in
        switch item {
        case .dormitory, .gender, .period, .habit:
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OnboardingButtonCell.identifier,
            for: indexPath
          ) as? OnboardingButtonCell else {
            return UICollectionViewCell()
          }
          cell.buttonTappedHandler = { item in
            self.reactor?.action.onNext(.itemDidChange(item))
          }
          cell.configure(with: item)
          return cell
          
        case .age:
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OnboardingAgeCell.identifier,
            for: indexPath
          ) as? OnboardingAgeCell else {
            return UICollectionViewCell()
          }
          cell.ageTextFieldHandler = {
            self.reactor?.action.onNext(.itemDidChange($0))
          }
          return cell
          
        case .wantToSay(let text):
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OnboardingTextViewCell.identifier,
            for: indexPath
          ) as? OnboardingTextViewCell else {
            return UICollectionViewCell()
          }
          cell.configure(with: text)
          cell.textViewHandler = {
            self.reactor?.action.onNext(.itemDidChange(.wantToSay($0)))
            self.onboardingHeaderView?.updateCurrentLength($0)
          }
          return cell

        default:
          guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OnboardingTextFieldCell.identifier,
            for: indexPath
          ) as? OnboardingTextFieldCell else {
            return UICollectionViewCell()
          }
          cell.configure(with: item)
          return cell
        }
      }
    )
    dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
      guard let section = self.dataSource.sectionIdentifier(for: indexPath.section)
      else { return UICollectionReusableView() }
      switch kind {
      case OnboardingHeaderView.identifier:
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: OnboardingHeaderView.identifier,
          for: indexPath
        ) as? OnboardingHeaderView else {
          return UICollectionReusableView()
        }
        headerView.configure(with: section)
        if case .wantToSay = section {
          self.onboardingHeaderView = headerView
        }
        return headerView
        
      case OnboardingFooterView.identifier:
        guard let footerView = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: OnboardingFooterView.identifier,
          for: indexPath
        ) as? OnboardingFooterView else {
          return UICollectionReusableView()
        }
        return footerView
      default:
        fatalError("❌ 알 수 없는 식별자입니다!")
      }
    }
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
  
  func bind(reactor: OnboardingViewReactor2) {
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
    
    // State
    
    reactor.state.map { $0.viewType }
      .distinctUntilChanged()
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, viewType in
        switch viewType {
        case .signUp:
          owner.navigationItem.title = "내 정보 입력"
          owner.bottomMenuView.updateTitle(left: "정보 입력 건너 뛰기", right: "완료")
        case .theFirstTime:
          break
        case .correction:
          break
        }
      }
      .disposed(by: self.disposeBag)
    
    reactor.state.map { (section: $0.sections, items: $0.items) }
      .asDriver(onErrorRecover: { _ in return .empty() })
      .drive(with: self) { owner, sectionData in
        var snapshot = NSDiffableDataSourceSnapshot<OnboardingSection, OnboardingSectionItem>()
        snapshot.appendSections(sectionData.section)
        sectionData.items.enumerated().forEach { index, items in
          snapshot.appendItems(items, toSection: sectionData.section[index])
        }
        DispatchQueue.main.async {
          owner.dataSource.apply(snapshot)
        }
      }
      .disposed(by: self.disposeBag)
    
//    rx.viewDidLoad
//      .withUnretained(self)
//      .filter { $0.0.type == .modify }
//      .map { _ in UserStorage.shared.matchingInfo }
//      .filterNil()
//      .map { OnboardingViewReactor.Action.viewDidLoad($0) }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    // 1기숙사 버튼 클릭
//    dorm1Button.rx.tap
//      .withUnretained(self)
//      .do(onNext: {
//        $0.0.dorm1Button.isSelected = true
//        $0.0.dorm2Button.isSelected = false
//        $0.0.dorm3Button.isSelected = false
//      })
//      .map { _ in OnboardingViewReactor.Action.didTapDormButton(.no1) }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    // 2기숙사 버튼 클릭
//    dorm2Button.rx.tap
//      .withUnretained(self)
//      .do {
//        $0.0.dorm1Button.isSelected = false
//        $0.0.dorm2Button.isSelected = true
//        $0.0.dorm3Button.isSelected = false
//      }
//      .map { _ in OnboardingViewReactor.Action.didTapDormButton(.no2) }
//      .debug()
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    // 3기숙사 버튼 클릭
//    dorm3Button.rx.tap
//      .withUnretained(self)
//      .do {
//        $0.0.dorm1Button.isSelected = false
//        $0.0.dorm2Button.isSelected = false
//        $0.0.dorm3Button.isSelected = true
//      }
//      .map { _ in OnboardingViewReactor.Action.didTapDormButton(.no3) }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    // 남자 버튼 클릭
//    maleButton.rx.tap
//      .withUnretained(self)
//      .do {
//        $0.0.maleButton.isSelected = true
//        $0.0.femaleButton.isSelected = false
//      }
//      .map { _ in OnboardingViewReactor.Action.didTapGenderButton(.male)}
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    // 여자 버튼 클릭
//    femaleButton.rx.tap
//      .withUnretained(self)
//      .do {
//        $0.0.maleButton.isSelected = false
//        $0.0.femaleButton.isSelected = true
//      }
//      .map { _ in OnboardingViewReactor.Action.didTapGenderButton(.female) }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    // 16주 버튼 클릭
//    period16Button.rx.tap
//      .withUnretained(self)
//      .do {
//        $0.0.period16Button.isSelected = true
//        $0.0.period24Button.isSelected = false
//      }
//      .map { _ in OnboardingViewReactor.Action.didTapJoinPeriodButton(.period_16) }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    // 24주 버튼 클릭
//    period24Button.rx.tap
//      .withUnretained(self)
//      .do {
//        $0.0.period16Button.isSelected = false
//        $0.0.period24Button.isSelected = true
//      }
//      .map { _ in OnboardingViewReactor.Action.didTapJoinPeriodButton(.period_24) }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    // 흡연 버튼 클릭
//    smokingButton.rx.tap
//      .withUnretained(self)
//      .do { $0.0.smokingButton.isSelected = !$0.0.smokingButton.isSelected }
//      .map { $0.0.smokingButton.isSelected }
//      .map { OnboardingViewReactor.Action.didTapHabitButton(.smoking, $0) }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    // 코골이 버튼 클릭
//    snoreButton.rx.tap
//      .withUnretained(self)
//      .do { $0.0.snoreButton.isSelected = !$0.0.snoreButton.isSelected }
//      .map { $0.0.snoreButton.isSelected }
//      .map { OnboardingViewReactor.Action.didTapHabitButton(.snoring, $0) }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    // 이갈이 버튼 클릭
//    grindingButton.rx.tap
//      .withUnretained(self)
//      .do { $0.0.grindingButton.isSelected = !$0.0.grindingButton.isSelected }
//      .map { $0.0.grindingButton.isSelected }
//      .map { OnboardingViewReactor.Action.didTapHabitButton(.grinding, $0) }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    // 음식 허용 버튼 클릭
//    allowedFoodButton.rx.tap
//      .withUnretained(self)
//      .do { $0.0.allowedFoodButton.isSelected = !$0.0.allowedFoodButton.isSelected }
//      .map { $0.0.allowedFoodButton.isSelected }
//      .map { OnboardingViewReactor.Action.didTapHabitButton(.allowedFood, $0) }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    // 이어폰 허용 버튼 클릭
//    allowedEarphoneButton.rx.tap
//      .withUnretained(self)
//      .do { $0.0.allowedEarphoneButton.isSelected = !$0.0.allowedEarphoneButton.isSelected }
//      .map { $0.0.allowedEarphoneButton.isSelected }
//      .map { OnboardingViewReactor.Action.didTapHabitButton(.allowedEarphone, $0) }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    // 나이 텍스트 반응
//    ageTextField.rx.text
//      .orEmpty
//      .skip(1)
//      .map { OnboardingViewReactor.Action.didChangeAgeTextField($0) }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    // 기상시간 텍스트필드
//    wakeUpTextField.textField.rx.text
//      .orEmpty
//      .skip(1)
//      .map { OnboardingViewReactor.Action.didChangeWakeUpTextField($0) }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    // 정리정돈 텍스트필드
//    cleanUpTextField.textField.rx.text
//      .orEmpty
//      .skip(1)
//      .map { OnboardingViewReactor.Action.didChangeCleanUpTextField($0) }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    // 샤워시간 텍스트필드
//    showerTextField.textField.rx.text
//      .orEmpty
//      .skip(1)
//      .map { OnboardingViewReactor.Action.didChangeShowerTextField($0) }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    chatTextField.isDefault = false
//    
//    // 오픈카카오 텍스트필드
//    chatTextField.textField.rx.text
//      .orEmpty
//      .skip(1)
//      .distinctUntilChanged()
//      .map { OnboardingViewReactor.Action.didChangeChatTextField($0) }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    // 오픈카카오 텍스트필드 포커싱 해제
//    chatTextField.textField.rx.controlEvent(.editingDidEnd)
//      .withUnretained(self)
//      .map { $0.0.chatTextField.textField.text }
//      .filterNil()
//      .map { OnboardingViewReactor.Action.didEndEditingChatTextField($0) }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    let mbtiObservable = mbtiTextField.textField.rx.text
//      .orEmpty
//      .scan("") { previous, new in
//        if new.count > 4 {
//          return previous
//        } else {
//          return new
//        }
//      }
//      .share()
//    
//    mbtiObservable
//      .bind(to: mbtiTextField.textField.rx.text)
//      .disposed(by: disposeBag)
//    
//    mbtiObservable
//      .debug()
//      .map { return OnboardingViewReactor.Action.didChangeMbtiTextField($0) }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    let wishTextObservable = wishTextView.rx.text
//      .orEmpty
//      .scan("") { previous, new in
//        if new.count > 100 {
//          return previous
//        } else {
//          return new
//        }
//      }
//    
//    wishTextObservable
//      .bind(to: wishTextView.rx.text)
//      .disposed(by: disposeBag)
//    
//    wishTextObservable
//      .map { OnboardingViewReactor.Action.didChangeWishTextView($0) }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    // FloatyBottomView 왼쪽 버튼
//    floatyBottomView.leftButton.rx.tap
//      .map { OnboardingViewReactor.Action.didTapLeftButton }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    // FloatyBottomView 오른쪽 버튼
//    floatyBottomView.rightButton.rx.tap
//      .map { OnboardingViewReactor.Action.didTapRightButton }
//      .bind(to: reactor.action)
//      .disposed(by: disposeBag)
//    
//    // 빈 공간 터치 시 키보드 내림
//    scrollView.rx.tapGesture(configuration: { _, delegate in
//      delegate.simultaneousRecognitionPolicy = .never
//    })
//    .when(.recognized)
//    .withUnretained(self)
//    .bind { $0.0.view.endEditing(true) }
//    .disposed(by: disposeBag)
//    
//    // 화면 최초 접속
//    rx.viewDidLoad
//      .withUnretained(self)
//      .filter { $0.0.type == .modify }
//      .map { _ in UserStorage.shared.matchingInfo }
//      .filterNil()
//      .withUnretained(self)
//      .bind { owner, info in
//        switch info.dormCategory {
//        case .no1: owner.dorm1Button.isSelected = true
//        case .no2: owner.dorm2Button.isSelected = true
//        case .no3: owner.dorm3Button.isSelected = true
//        }
//        
//        switch info.gender {
//        case .male: owner.maleButton.isSelected = true
//        case .female: owner.femaleButton.isSelected = true
//        }
//        
//        switch info.joinPeriod {
//        case .period_16: owner.period16Button.isSelected = true
//        case .period_24: owner.period24Button.isSelected = true
//        }
//        
//        owner.snoreButton.isSelected = info.isSnoring
//        owner.grindingButton.isSelected = info.isGrinding
//        owner.smokingButton.isSelected = info.isSmoking
//        owner.allowedFoodButton.isSelected = info.isAllowedFood
//        owner.allowedEarphoneButton.isSelected = info.isWearEarphones
//        owner.ageTextField.setText(String(info.age))
//        owner.ageTextField.rx.text.onNext(String(info.age))
//        owner.wakeUpTextField.textField.rx.text.onNext(info.wakeUpTime)
//        owner.cleanUpTextField.textField.text = info.cleanUpStatus
//        owner.showerTextField.textField.text = info.showerTime
//        owner.mbtiTextField.textField.text = info.mbti
//        owner.chatTextField.textField.text = info.openKakaoLink
//        owner.wishTextView.text = info.wishText
//        
//        [
//          owner.wakeUpTextField.checkmarkButton,
//          owner.cleanUpTextField.checkmarkButton,
//          owner.showerTextField.checkmarkButton,
//          owner.chatTextField.checkmarkButton,
//          owner.mbtiTextField.checkmarkButton
//        ].forEach { $0.isHidden = false }
//        
//        if info.mbti == nil || info.mbti == "" {
//          owner.mbtiTextField.checkmarkButton.isHidden = true
//        }
//      }
//      .disposed(by: disposeBag)
//    
//    // MARK: - State
//    
//    // 인디케이터 애니메이션
//    reactor.state
//      .map { $0.isLoading }
//      .bind(to: indicator.rx.isAnimating)
//      .disposed(by: disposeBag)
//    
//    // 완료 버튼 활성화/비활성화
//    reactor.state
//      .map { $0.currentDriver }
//      .flatMap { $0.isEnabled }
//      .bind(to: floatyBottomView.rightButton.rx.isEnabled)
//      .disposed(by: disposeBag)
//    
//    // MainVC로 이동
//    reactor.state
//      .map { $0.isOpenedMainVC }
//      .filter { $0 }
//      .withUnretained(self)
//      .bind { owner, _ in
//        let mainVC = TabBarViewController()
//        mainVC.modalPresentationStyle = .fullScreen
//        owner.present(mainVC, animated: true)
//      }
//      .disposed(by: disposeBag)
//    
//    // 선택초기화
//    reactor.state
//      .map { $0.isCleared }
//      .filter { $0 }
//      .withUnretained(self)
//      .bind { owner, _ in
//        [
//          owner.dorm1Button, owner.dorm2Button, owner.dorm3Button,
//          owner.maleButton, owner.femaleButton,
//          owner.period16Button, owner.period24Button,
//          owner.smokingButton,
//          owner.snoreButton,
//          owner.grindingButton,
//          owner.allowedFoodButton,
//          owner.allowedEarphoneButton
//        ]
//          .forEach { $0.isSelected = false }
//        
//        [
//          owner.wakeUpTextField.textField,
//          owner.cleanUpTextField.textField,
//          owner.showerTextField.textField,
//          owner.chatTextField.textField,
//          owner.mbtiTextField.textField,
//        ]
//          .forEach { $0.text = "" }
//        
//        [
//          owner.wakeUpTextField.checkmarkButton,
//          owner.cleanUpTextField.checkmarkButton,
//          owner.showerTextField.checkmarkButton,
//          owner.chatTextField.checkmarkButton,
//          owner.mbtiTextField.checkmarkButton
//        ]
//          .forEach { $0.isHidden = true }
//        
//        owner.wishTextView.text = ""
//        owner.ageTextField.clearOTP()
//      }
//      .disposed(by: disposeBag)
//    
//    // RootVC로 이동
//    reactor.state
//      .map { $0.isOpenedRootVC }
//      .filter { $0 }
//      .withUnretained(self)
//      .bind { $0.0.navigationController?.popToRootViewController(animated: true) }
//      .disposed(by: disposeBag)
//    
//    // OnboardingDetailVC로 이동
//    reactor.state
//      .map { $0.isOpenedOnboardingDetailVC }
//      .filter { $0.0 }
//      .withUnretained(self)
//      .bind { owner, member in
//        let onboardingDetailVC = OnboardingDetailViewController(member.1, type: owner.type)
//        onboardingDetailVC.reactor = OnboardingDetailViewReactor(owner.type)
//        owner.navigationController?.pushViewController(onboardingDetailVC, animated: true)
//      }
//      .disposed(by: disposeBag)
//    
//    // ChatTextField 모서리 색상
//    reactor.state
//      .map { $0.currentChatBorderColor }
//      .map { $0.cgColor }
//      .bind(to: chatTextField.layer.rx.borderColor)
//      .disposed(by: disposeBag)
//    
//    // ChatTextField 체크마크 숨김
//    reactor.state
//      .map { $0.isHiddenChatTfCheckmark }
//      .bind(to: chatTextField.checkmarkButton.rx.isHidden)
//      .disposed(by: disposeBag)
//    
//    // ChatDescriptionLabel 텍스트 색상
//    reactor.state
//      .map { $0.currentChatDescriptionTextColor }
//      .bind(to: chatDescriptionLabel.rx.textColor)
//      .disposed(by: disposeBag)
//    
//    // 오류 팝업 창
//    reactor.state
//      .map { $0.isOpenedKakaoPopup }
//      .filter { $0 }
//      .withUnretained(self)
//      .bind { owner, _ in
//        let popup = iDormPopupViewController(contents:
//          """
//          올바른 형식의 링크가 아닙니다.
//          open.kakao 형식을 포함했는지 확인해주세요.
//          """
//        )
//        popup.modalPresentationStyle = .overFullScreen
//        owner.present(popup, animated: false)
//      }
//      .disposed(by: disposeBag)
//    
//    // 현재 하고싶은 말 TextView 글자 수
//    reactor.state
//      .map { $0.currentWishTextCount }
//      .map { String($0) }
//      .bind(to: currentLengthLabel.rx.text)
//      .disposed(by: disposeBag)
//    
//    reactor.state.map { $0.showPopup }
//      .filter { $0.0 }
//      .bind(with: self) { owner, contents in
//        let popup = iDormPopupViewController(contents: contents.1)
//        popup.modalPresentationStyle = .overFullScreen
//        owner.present(popup, animated: false)
//      }
//      .disposed(by: self.disposeBag)
  }
  
  // MARK: - Setup
  
  /// 클립보드에 있는 텍스트를 URL형식의 String으로 변환해주는 메서드입니다.
  func extractLinkFromText(_ text: String) -> String? {
    let pattern = "(?i)https?://(?:www\\.)?\\S+(?:/|\\b)"
    
    guard let regex = try? NSRegularExpression(
      pattern: pattern,
      options: []
    ) else {
      return nil
    }
    
    if let result = regex.firstMatch(
      in: text,
      options: [],
      range: NSRange(location: 0, length: text.utf16.count)
    ) {
      let url = (text as NSString).substring(with: result.range)
      return url
    }
    return nil
  }
}

// MARK: - Privates

private extension OnboardingViewController {
  func getLayout() -> UICollectionViewCompositionalLayout {
    return UICollectionViewCompositionalLayout { section, _ in
      guard let section = self.dataSource.sectionIdentifier(for: section) else {
        fatalError("❌ OnboardingSection을 발견하지 못했습니다!")
      }
      return section.section
    }
  }
}
