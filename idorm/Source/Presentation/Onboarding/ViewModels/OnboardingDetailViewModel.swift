//
//  OnboardingDetailViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/09/10.
//

import Foundation
import RxSwift
import RxCocoa

class OnboardingDetailViewModel {
  struct Input {
    let didTapBackButton = PublishSubject<Void>()
    let didTapConfirmButton = PublishSubject<Void>()
  }
  
  struct Output {
    let popVC = PublishSubject<Void>()
    let showPopupVC = PublishSubject<String>()
    let showTabBarVC = PublishSubject<Void>()
    let startAnimation = PublishSubject<Void>()
    let stopAnimation = PublishSubject<Void>()
  }
  
  let input = Input()
  let output = Output()
  let disposeBag = DisposeBag()
  
  let matchingInfo: MatchingInfo
  
  init(_ matchingInfo: MatchingInfo) {
    self.matchingInfo = matchingInfo
    bind()
  }
  
  func bind() {
    /// 이전 화면으로 돌아가기
    input.didTapBackButton
      .bind(to: output.popVC)
      .disposed(by: disposeBag)
    
    /// 매칭 최초 저장
    input.didTapConfirmButton
      .bind(onNext: { [weak self] in
        self?.output.startAnimation.onNext(Void())
        self?.matchingInfoAPI()
      })
      .disposed(by: disposeBag)
  }
  
  func matchingInfoAPI() {
    OnboardingService.matchingInfoAPI_Post(myinfo: matchingInfo)
      .subscribe(onNext: { [weak self] response in
        self?.output.stopAnimation.onNext(Void())
        let statusCode = response.response?.statusCode
        // TODO: [] StatusCode가 response로 오지않음
        print(statusCode)
        switch statusCode {
        case 200:
          self?.output.showTabBarVC.onNext(Void())
        case 401:
          self?.output.showPopupVC.onNext("로그인한 멤버가 존재하지 않습니다.")
        case 404:
          self?.output.showPopupVC.onNext("멤버를 찾을 수 없습니다.")
        case 409:
          self?.output.showPopupVC.onNext("이미 등록된 매칭 정보가 있습니다.")
        case 500:
          self?.output.showPopupVC.onNext("Matching save 중 서버 에러 발생")
        default:
          fatalError()
        }
      })
      .disposed(by: disposeBag)
  }
}
