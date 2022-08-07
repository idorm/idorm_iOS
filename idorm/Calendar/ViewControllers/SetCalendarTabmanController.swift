//
//  CalendarPostDetailViewController.swift
//  idorm
//
//  Created by 김응철 on 2022/08/03.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import PanModal
import Pageboy
import Tabman

class SetCalendarTabmanController: TabmanViewController {
  // MARK: - Properties
  var viewControllers: [UIViewController] = []
  
  lazy var tabmanBar: TMBar.ButtonBar = {
    let bar = TMBar.ButtonBar()
    bar.layout.separatorColor = .black
    bar.layout.contentMode = .fit
    bar.indicator.tintColor = .black
    bar.indicator.weight = .custom(value: 1)
    bar.backgroundColor = .white
    
    return bar
  }()
  
  lazy var startSetCalendarVC = SetCalendarViewController(type: .start, viewModel: viewModel)
  lazy var endSetCalendarVC = SetCalendarViewController(type: .end, viewModel: viewModel)
  
  let viewModel = SetCalendarViewModel()
  let disposeBag = DisposeBag()
  
  /// DatePicker로 선택된 시간
  var startTime = BehaviorRelay<Date>(value: .now)
  var endTime = BehaviorRelay<Date>(value: .now)
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    bind()
  }
  
  // MARK: - Bind
  private func bind() {
    // --------------------
    //        Input
    // --------------------
    // 하루종일 버튼 클릭시 동기화
    viewModel.input.allDayButtonState
      .asDriver()
      .drive(onNext: {
        [weak self] isSelected in
          self?.startSetCalendarVC.allDayButton.isSelected = isSelected
          self?.endSetCalendarVC.allDayButton.isSelected = isSelected
      })
      .disposed(by: disposeBag)
    
    // DatePicker 값 변경 시 스트림 생성
    startSetCalendarVC.datePicker.rx.controlEvent(.valueChanged)
      .map { [weak self] in
        guard let self = self else { return .now }
        return self.startSetCalendarVC.datePicker.date
      }
      .bind(to: viewModel.input.startTime)
      .disposed(by: disposeBag)
    
    endSetCalendarVC.datePicker.rx.controlEvent(.valueChanged)
      .map { [weak self] in
        guard let self = self else { return .now }
        return self.endSetCalendarVC.datePicker.date
      }
      .bind(to: viewModel.input.endTime)
      .disposed(by: disposeBag)
    
    // 선택한 시작, 종료 날짜 스트림 생성
    startSetCalendarVC.calendarView.selectedDateSubject
      .bind(to: viewModel.input.startDate)
      .disposed(by: disposeBag)
    
    endSetCalendarVC.calendarView.selectedDateSubject
      .bind(to: viewModel.input.endDate)
      .disposed(by: disposeBag)
    
    // 하루종일 버튼 동기화
    Observable.merge(
      startSetCalendarVC.allDayButton.rx.tap.asObservable(),
      endSetCalendarVC.allDayButton.rx.tap.asObservable()
    )
    .map { [weak self] in
      guard let self = self else { return }
      self.startSetCalendarVC.allDayButton.isSelected = !self.startSetCalendarVC.allDayButton.isSelected
      self.endSetCalendarVC.allDayButton.isSelected = !self.endSetCalendarVC.allDayButton.isSelected
    }
    .map { [weak self] in
      guard let self = self else { return false }
      return self.startSetCalendarVC.allDayButton.isSelected
    }
    .bind(to: viewModel.input.allDayButtonState)
    .disposed(by: disposeBag)
    
    // 완료버튼 선택
    Observable.merge(
      startSetCalendarVC.confirmButton.rx.tap.asObservable(),
      endSetCalendarVC.confirmButton.rx.tap.asObservable()
    )
    .bind(to: viewModel.input.selectConfirmButton)
    .disposed(by: disposeBag)
    
    // --------------------
    //        Output
    // --------------------
    // 에러페이지 보여주기
    viewModel.output.showErrorPage
      .bind(onNext: { [weak self] in
        let popupVC = PopupViewController(contents: "시작 날짜는 종료 날짜 이전이어야 합니다.")
        self?.present(popupVC, animated: false)
      })
      .disposed(by: disposeBag)
    
    // 완료 버튼 누를 시에 데이터 전달 후, Dismiss
    viewModel.output.changedCalendarDate
      .bind(onNext: { [weak self] _ in
        self?.dismiss(animated: true)
      })
      .disposed(by: disposeBag)
  }
  
  // MARK: - Helpers
  private func configureUI() {
    view.backgroundColor = .white
    viewControllers.append(startSetCalendarVC)
    viewControllers.append(endSetCalendarVC)
    
    tabmanBar.buttons.customize { button in
      button.selectedTintColor = .black
      button.tintColor = .idorm_gray_200
      button.font = .init(name: Font.regular.rawValue, size: 14)!
      button.selectedFont = .init(name: Font.regular.rawValue, size: 14)!
      button.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    }
    
    self.dataSource = self
    addBar(tabmanBar, dataSource: self, at: .top)
  }
}

extension SetCalendarTabmanController: PageboyViewControllerDataSource, TMBarDataSource {
  func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
    viewControllers.count
  }
  
  func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
    viewControllers[index]
  }
  
  func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
    return nil
  }
  
  func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
    if index == 0 {
      let item = TMBarItem(title: "시작")
      return item
    } else {
      let item = TMBarItem(title: "종료")
      return item
    }
  }
}

extension SetCalendarTabmanController: PanModalPresentable {
  var panScrollable: UIScrollView? {
    return nil
  }
  
  var shortFormHeight: PanModalHeight {
    return PanModalHeight.contentHeight(710)
  }
  
  var longFormHeight: PanModalHeight {
    return PanModalHeight.contentHeight(710)
  }
}
