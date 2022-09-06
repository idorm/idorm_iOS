//
//  SetCalendarViewModel.swift
//  idorm
//
//  Created by 김응철 on 2022/08/04.
//

import RxSwift
import RxCocoa
import Foundation

class SetCalendarViewModel {
  struct Input {
    let startDate = BehaviorRelay<Date>(value: Date())
    let endDate = BehaviorRelay<Date>(value: Date())
    let startTime = BehaviorRelay<Date>(value: Date())
    let endTime = BehaviorRelay<Date>(value: Date())
    let allDayButtonState = BehaviorRelay<Bool>(value: false)
    let selectConfirmButton = PublishSubject<Void>()
  }
  
  struct Output {
    let showErrorPage = PublishSubject<Void>()
    let changedCalendarDate = PublishSubject<(start: Date, end: Date)>()
  }
  
  let input = Input()
  let output = Output()
  let disposeBag = DisposeBag()
  
  init() {
    bind()
  }
  
  func bind() {
    input.selectConfirmButton
      .bind(onNext: { [weak self] in
        guard let self = self else { return }
        let calendar = Calendar.current
        let timezone = TimeZone(secondsFromGMT: 0)!
        
        let startYear = calendar.component(.year, from: self.input.startDate.value)
        let startMonth = calendar.component(.month, from: self.input.startDate.value)
        let startDay = calendar.component(.day, from: self.input.startDate.value)
        let startHour = calendar.component(.hour, from: self.input.startTime.value)
        let startMinute = calendar.component(.minute, from: self.input.startTime.value)
        
        var startDateComponents = DateComponents()
        startDateComponents.timeZone = timezone
        startDateComponents.year = startYear
        startDateComponents.month = startMonth
        startDateComponents.day = startDay
        startDateComponents.hour = startHour
        startDateComponents.minute = startMinute
        
        let endYear = calendar.component(.year, from: self.input.endDate.value)
        let endMonth = calendar.component(.month, from: self.input.endDate.value)
        let endDay = calendar.component(.day, from: self.input.endDate.value)
        let endHour = calendar.component(.hour, from: self.input.endTime.value)
        let endMinute = calendar.component(.minute, from: self.input.endTime.value)
        
        var endDateComponents = DateComponents()
        endDateComponents.timeZone = timezone
        endDateComponents.year = endYear
        endDateComponents.month = endMonth
        endDateComponents.day = endDay
        endDateComponents.hour = endHour
        endDateComponents.minute = endMinute
        
        let startDate = calendar.date(from: startDateComponents)!
        let endDate = calendar.date(from: endDateComponents)!
        let result: ComparisonResult = startDate.compare(endDate)
        
        if result == .orderedDescending || result == .orderedSame {
          self.output.showErrorPage.onNext(print("ShowErrorPage!"))
        } else {
          self.output.changedCalendarDate.onNext((startDate, endDate))
        }
      })
      .disposed(by: disposeBag)
  }
}
