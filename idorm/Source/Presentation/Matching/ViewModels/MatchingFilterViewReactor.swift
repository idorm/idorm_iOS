//
//  MatchingFilterViewReactor.swift
//  idorm
//
//  Created by 김응철 on 2022/12/19.
//

import RxSwift
import RxCocoa
import ReactorKit

final class MatchingFilterViewReactor: Reactor {
  
  enum Action {
    case didTapResetButton
    case didTapConfirmButton
    case didTapDormButton(Dormitory)
    case didTapJoinPeriodButton(JoinPeriod)
    case didTapHabitButton(Habit)
    // TODO: Slider 필터 정보 넣기
  }
  
  enum Mutation {
    case updatePopVC
    case updateRequestCard
    case updateFilter(MatchingDTO.Filter)
  }
  
  struct State {
    var popVC: Bool = false
    var requestCard: Bool = false
    var filter = FilterStorage.shared.filter
  }
  
  let initialState: State = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    var newFilter = FilterStorage.shared.filter
    
    switch action {
    case .didTapResetButton:
      FilterStorage.shared.resetFilter()
      FilterDriver.shared.reset()
      return Observable.just(.updatePopVC)
      
    case .didTapConfirmButton:
      return Observable.concat([
        Observable.just(.updatePopVC),
        Observable.just(.updateRequestCard)
      ])
      
    case .didTapDormButton(let dorm):
      FilterDriver.shared.dorm.accept(true)
      newFilter.dormNum = dorm
      return Observable.just(.updateFilter(newFilter))

    case .didTapJoinPeriodButton(let period):
      FilterDriver.shared.joinPeriod.accept(true)
      newFilter.joinPeriod = period
      return Observable.just(.updateFilter(newFilter))
      
    case .didTapHabitButton(let habit):
      switch habit {
      case .snoring:
        newFilter.isSnoring = !newFilter.isSnoring
      case .smoking:
        newFilter.isSmoking = !newFilter.isSmoking
      case .grinding:
        newFilter.isGrinding = !newFilter.isGrinding
      case .allowedEarphone:
        newFilter.isWearEarphones = !newFilter.isWearEarphones
      case .allowedFood:
        newFilter.isAllowedFood = !newFilter.isAllowedFood
      }
      return Observable.just(.updateFilter(newFilter))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    
    switch mutation {
    case .updatePopVC:
      newState.popVC = true
      
    case .updateRequestCard:
      newState.requestCard = true
      
    case .updateFilter(let newFilter):
      FilterStorage.shared.saveFilter(newFilter)
    }
    
    return newState
  }
  
  struct Input {
    // UI
    let skipButtonTapped = PublishSubject<Void>()
    let confirmButtonTapped = PublishSubject<Void>()
    let isSelectedDormButton = PublishSubject<Dormitory>()
    let isSelectedPeriodButton = PublishSubject<JoinPeriod>()
    let isSelectedHabitButton = PublishSubject<Habit>()
    let onChangedAgeSlider = PublishSubject<(minAge: Int, maxAge: Int)>()
  }
  
  struct Output {
    // Presentation
    let popVC = PublishSubject<Void>()
    
    // UI
    let isEnableConfirmButton = PublishSubject<Bool>()
    
    // Card
    let requestCards = PublishSubject<Void>()
    let requestFilteredCards = PublishSubject<Void>()
  }
  
  var input = Input()
  var output = Output()
  var disposeBag = DisposeBag()
  
  init() {
    
    // 필터링 완료 버튼 드라이버 -> Bool Stream 전달
    FilterDriver.shared.isAllowed
      .bind(to: output.isEnableConfirmButton)
      .disposed(by: disposeBag)
    
    // 필터 초기화 버튼 클릭 -> 카드 다시 요청
    input.skipButtonTapped
      .bind(to: output.requestCards)
      .disposed(by: disposeBag)
        
    // 선택 초기화 버튼 -> 뒤로 가기 & 매칭 필터 정보 초기화
    input.skipButtonTapped
      .withUnretained(self)
      .bind { owner, _ in
        owner.output.popVC.onNext(Void())
        owner.output.requestCards.onNext(Void())
      }
      .disposed(by: disposeBag)
    
    // 선택 초기화 버튼 -> 뒤로가기
    input.skipButtonTapped
    
    
    // 선택 초기화 버튼 -> 스토리지 & 드라이버 리셋
    input.skipButtonTapped
      .bind {
        FilterDriver.shared.reset()
        FilterStorage.shared.resetFilter()
      }
      .disposed(by: disposeBag)
    
    // 필터링 완료 버튼 이벤트 -> 뒤로가기 & 필터 매칭 카드 요청
    input.confirmButtonTapped
      .withUnretained(self)
      .bind(onNext: { owner, _ in
        owner.output.popVC.onNext(Void())
        owner.output.requestFilteredCards.onNext(Void())
      })
      .disposed(by: disposeBag)
    
    // 기숙사 버튼 -> 기숙사 드라이버 활성화
    input.isSelectedDormButton
      .map { _ in true }
      .bind(to: FilterDriver.shared.dorm)
      .disposed(by: disposeBag)
    
    // 입사 기간 버튼 -> 입사 기간 드라이버 활성화
    input.isSelectedPeriodButton
      .map { _ in true }
      .bind(to: FilterDriver.shared.joinPeriod)
      .disposed(by: disposeBag)
    
    // 기숙사 버튼 이벤트 -> 필터 업데이트
    input.isSelectedDormButton
      .bind { dorm in
        var newFilter = FilterStorage.shared.filter
        switch dorm {
        case .no1:
          newFilter.dormNum = .no1
        case .no2:
          newFilter.dormNum = .no2
        case .no3:
          newFilter.dormNum = .no3
        }
        FilterStorage.shared.saveFilter(newFilter)
      }
      .disposed(by: disposeBag)
    
    // 기간 버튼 이벤트 -> 매칭필터 정보 전달 & 필터링 버튼 드라이버 전달
    input.isSelectedPeriodButton
      .bind { period in
        var newFilter = FilterStorage.shared.filter
        switch period {
        case .period_16:
          newFilter.joinPeriod = .period_16
        case .period_24:
          newFilter.joinPeriod = .period_24
        }
        FilterStorage.shared.saveFilter(newFilter)
      }
      .disposed(by: disposeBag)
    
    // 습관 버튼 이벤트 -> 매칭 필터 정보 전달
    input.isSelectedHabitButton
      .bind { habit in
        var newFilter = FilterStorage.shared.filter
        switch habit {
        case .snoring:
          newFilter.isSnoring.toggle()
        case .smoking:
          newFilter.isSmoking.toggle()
        case .grinding:
          newFilter.isGrinding.toggle()
        case .allowedFood:
          newFilter.isAllowedFood.toggle()
        case .allowedEarphone:
          newFilter.isWearEarphones.toggle()
        }
        FilterStorage.shared.saveFilter(newFilter)
      }
      .disposed(by: disposeBag)
    
    // 나이 슬라이더 이벤트 -> 매칭 필터 정보 전달
    input.onChangedAgeSlider
      .debug()
      .bind { (minValue, maxValue) in
        var newFilter = FilterStorage.shared.filter
        newFilter.minAge = minValue
        newFilter.maxAge = maxValue
        FilterStorage.shared.saveFilter(newFilter)
      }
      .disposed(by: disposeBag)
  }
}
