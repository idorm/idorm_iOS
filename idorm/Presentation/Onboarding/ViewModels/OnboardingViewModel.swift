//
//  OnboardingViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/07/08.
//

import RxSwift
import RxCocoa

class OnboardingViewModel {
  // MARK: - Properties
  struct Input {
    let dorm1ButtonTapped = BehaviorRelay<Bool>(value: false)
    let dorm2ButtonTapped = BehaviorRelay<Bool>(value: false)
    let dorm3ButtonTapped = BehaviorRelay<Bool>(value: false)
    
    let maleButtonTapped = BehaviorRelay<Bool>(value: false)
    let femaleButtonTapped = BehaviorRelay<Bool>(value: false)
    
    let period16ButtonTapped = BehaviorRelay<Bool>(value: false)
    let period24ButtonTapped = BehaviorRelay<Bool>(value: false)
    
    let snoringButtonTapped = BehaviorRelay<Bool>(value: false)
    let grindingButtonTapped = BehaviorRelay<Bool>(value: false)
    let smokingButtonTapped = BehaviorRelay<Bool>(value: false)
    let allowedFoodButtonTapped = BehaviorRelay<Bool>(value: false)
    let allowedEarphoneButtonTapped = BehaviorRelay<Bool>(value: false)
    
    let ageTextFieldChanged = BehaviorRelay<String>(value: "")
    
    let wakeUpTimeTextFieldChanged = BehaviorRelay<String>(value: "")
    let cleanUpTimeTextFieldChanged = BehaviorRelay<String>(value: "")
    let showerTimeTextFieldChanged = BehaviorRelay<String>(value: "")
    let mbtiTextFieldChanged = BehaviorRelay<String>(value: "")
    let chatLinkTextFieldChanged = BehaviorRelay<String>(value: "")
    let wishTextTextFieldChanged = BehaviorRelay<String>(value: "")
    
    let didTapSkipButton = PublishSubject<Void>()
    let didTapConfirmButton = PublishSubject<Void>()
  }
  
  struct Output {
    let myInfo = BehaviorRelay<MyInfo?>(value: nil)
    let enableConfirmButton = PublishRelay<Bool>()
    let showOnboardingDetailVC = PublishSubject<MyInfo>()
  }
  
  var myInfo = MyInfo(dormNumber: .no1, period: .period_24, gender: .female, age: "", snoring: false, grinding: false, smoke: false, allowedFood: false, earphone: false, wakeupTime: "", cleanUpStatus: "", showerTime: "", mbti: "", wishText: "", chatLink: "") /// Accpet용
  let input = Input()
  let output = Output()
  let disposeBag = DisposeBag()
  
  var numberOfRowsInSection: Int {
    return OnboardingListType.allCases.count
  }
  
  func getQuestionText(index: Int) -> String {
    return OnboardingListType.allCases[index].query
  }
  
  init() {
    // 완료 버튼 활성화 비활성화
    output.myInfo.asObservable()
      .map {
        $0?.dormNumber != nil &&
        $0?.gender != nil &&
        $0?.period != nil &&
        $0?.age.isEmpty == false &&
        $0?.wakeupTime != "" &&
        $0?.cleanUpStatus != "" &&
        $0?.showerTime != ""
      }
      .bind(to: output.enableConfirmButton)
      .disposed(by: disposeBag)
    
    // 완료 버튼 클릭
    input.didTapConfirmButton
      .map { [unowned self] in
        self.myInfo
      }
      .bind(to: output.showOnboardingDetailVC)
      .disposed(by: disposeBag)
    
    input.dorm1ButtonTapped
      .subscribe(onNext: { [weak self] isSelected in
        if isSelected {
          self?.myInfo.dormNumber = .no1
          self?.output.myInfo.accept(self?.myInfo)
        }
      })
      .disposed(by: disposeBag)
    
    input.dorm2ButtonTapped
      .subscribe(onNext: { [weak self] isSelected in
        if isSelected {
          self?.myInfo.dormNumber = .no2
          self?.output.myInfo.accept(self?.myInfo)
        }
      })
      .disposed(by: disposeBag)

    input.dorm3ButtonTapped
      .subscribe(onNext: { [weak self] isSelected in
        if isSelected {
          self?.myInfo.dormNumber = .no3
          self?.output.myInfo.accept(self?.myInfo)
        }
      })
      .disposed(by: disposeBag)

    input.maleButtonTapped
      .subscribe(onNext: { [weak self] isSelected in
        if isSelected {
          self?.myInfo.gender = .male
          self?.output.myInfo.accept(self?.myInfo)
        }
      })
      .disposed(by: disposeBag)
    
    input.femaleButtonTapped
      .subscribe(onNext: { [weak self] isSelected in
        if isSelected {
          self?.myInfo.gender = .female
          self?.output.myInfo.accept(self?.myInfo)
        }
      })
      .disposed(by: disposeBag)

    input.period16ButtonTapped
      .subscribe(onNext: { [weak self] isSelected in
        if isSelected {
          self?.myInfo.period = .period_16
          self?.output.myInfo.accept(self?.myInfo)
        }
      })
      .disposed(by: disposeBag)
    
    input.period24ButtonTapped
      .subscribe(onNext: { [weak self] isSelected in
        if isSelected {
          self?.myInfo.period = .period_24
          self?.output.myInfo.accept(self?.myInfo)
        }
      })
      .disposed(by: disposeBag)
    
    input.snoringButtonTapped
      .subscribe(onNext: { [weak self] isSelected in
        self?.myInfo.snoring = isSelected
        self?.output.myInfo.accept(self?.myInfo)
      })
      .disposed(by: disposeBag)

    input.grindingButtonTapped
      .subscribe(onNext: { [weak self] isSelected in
        self?.myInfo.grinding = isSelected
        self?.output.myInfo.accept(self?.myInfo)
      })
      .disposed(by: disposeBag)

    input.smokingButtonTapped
      .subscribe(onNext: { [weak self] isSelected in
        self?.myInfo.smoke = isSelected
        self?.output.myInfo.accept(self?.myInfo)
      })
      .disposed(by: disposeBag)

    input.allowedFoodButtonTapped
      .subscribe(onNext: { [weak self] isSelected in
        self?.myInfo.allowedFood = isSelected
        self?.output.myInfo.accept(self?.myInfo)
      })
      .disposed(by: disposeBag)

    input.allowedEarphoneButtonTapped
      .subscribe(onNext: { [weak self] isSelected in
        self?.myInfo.earphone = isSelected
        self?.output.myInfo.accept(self?.myInfo)
      })
      .disposed(by: disposeBag)

    input.ageTextFieldChanged
      .subscribe(onNext: { [weak self] text in
        self?.myInfo.age = text
        self?.output.myInfo.accept(self?.myInfo)
      })
      .disposed(by: disposeBag)
    
    input.wakeUpTimeTextFieldChanged
      .subscribe(onNext: { [weak self] text in
        self?.myInfo.wakeupTime = text
        self?.output.myInfo.accept(self?.myInfo)
      })
      .disposed(by: disposeBag)
    
    input.cleanUpTimeTextFieldChanged
      .subscribe(onNext: { [weak self] text in
        self?.myInfo.cleanUpStatus = text
        self?.output.myInfo.accept(self?.myInfo)
      })
      .disposed(by: disposeBag)

    input.showerTimeTextFieldChanged
      .subscribe(onNext: { [weak self] text in
        self?.myInfo.showerTime = text
        self?.output.myInfo.accept(self?.myInfo)
      })
      .disposed(by: disposeBag)

    input.mbtiTextFieldChanged
      .subscribe(onNext: { [weak self] text in
        self?.myInfo.mbti = text
        self?.output.myInfo.accept(self?.myInfo)
      })
      .disposed(by: disposeBag)

    input.chatLinkTextFieldChanged
      .subscribe(onNext: { [weak self] text in
        self?.myInfo.chatLink = text
        self?.output.myInfo.accept(self?.myInfo)
      })
      .disposed(by: disposeBag)

    input.wishTextTextFieldChanged
      .subscribe(onNext: { [weak self] text in
        self?.myInfo.wishText = text
        self?.output.myInfo.accept(self?.myInfo)
      })
      .disposed(by: disposeBag)
  }
}
