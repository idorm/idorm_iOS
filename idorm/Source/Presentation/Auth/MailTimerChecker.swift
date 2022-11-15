import Foundation

import RxSwift
import RxCocoa

/// 인증번호 만료 시간을 계산하는 객체입니다.
final class MailTimerChecker {
  
  // MARK: - Properties
  
  let leftTime = BehaviorRelay<Int>(value: 300)
  let isPassed = PublishSubject<Bool>()
  private var currentValue = 0
  
  private var disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  // MARK: - Bind
  
  func bind() {
    let startTime = Date()
    
    // 1초마다 시간 재기
    Observable<Int>
      .interval(.seconds(1),
                scheduler: MainScheduler.instance)
      .withUnretained(self)
      .do(onNext: { weakself, countValue in
        let elapseSeconds = Int(Date().timeIntervalSince(startTime))
        weakself.leftTime.accept(300 - elapseSeconds)
      })
      .subscribe()
        .disposed(by: disposeBag)
        
        leftTime
        .subscribe(onNext: { [weak self] in
          if $0 < 0 {
            self?.isPassed.onNext(true)
          } else {
            self?.isPassed.onNext(false)
          }
        })
        .disposed(by: disposeBag)
        }
  
  func restart() {
    leftTime.accept(300)
  }
}
